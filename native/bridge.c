/* MIT. Independent syscall bridge; no Netlink protocol parsing lives here. */
#include "moonbit.h"
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#ifdef __linux__
#include <unistd.h>
#include <sys/socket.h>
#include <linux/netlink.h>
#include <poll.h>
#include <time.h>
#endif

typedef struct { int fd; int error; } mn_handle;

static void finalize(void *ptr) {
  mn_handle *h = ptr;
#ifdef __linux__
  if (h->fd >= 0) close(h->fd);
#endif
  h->fd = -1;
}

MOONBIT_FFI_EXPORT void *mn_open(uint32_t groups) {
  mn_handle *h = moonbit_make_external_object(finalize, sizeof(mn_handle));
  h->fd = -1; h->error = 95;
#ifdef __linux__
  h->fd = socket(AF_NETLINK, SOCK_RAW | SOCK_CLOEXEC | SOCK_NONBLOCK, NETLINK_ROUTE);
  if (h->fd < 0) { h->error = errno; return h; }
  struct sockaddr_nl addr = {0};
  addr.nl_family = AF_NETLINK; addr.nl_groups = groups;
  if (bind(h->fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
    h->error = errno; close(h->fd); h->fd = -1; return h;
  }
  int enabled = 1, buffer = 1048576;
  /* Optional enhancements; older kernels may reject these. */
  setsockopt(h->fd, SOL_NETLINK, NETLINK_EXT_ACK, &enabled, sizeof(enabled));
  setsockopt(h->fd, SOL_NETLINK, NETLINK_CAP_ACK, &enabled, sizeof(enabled));
  setsockopt(h->fd, SOL_SOCKET, SO_RCVBUF, &buffer, sizeof(buffer));
  h->error = 0;
#else
  (void)groups;
#endif
  return h;
}

MOONBIT_FFI_EXPORT int32_t mn_status(void *ptr) {
  mn_handle *h = ptr;
  return h->fd >= 0 ? h->fd : -(h->error ? h->error : 9);
}
MOONBIT_FFI_EXPORT void mn_close(void *ptr) { finalize(ptr); }
MOONBIT_FFI_EXPORT int32_t mn_little(void) {
  uint16_t n = 1; return *(uint8_t *)&n == 1;
}
MOONBIT_FFI_EXPORT int64_t mn_monotonic(void) {
#ifdef __linux__
  struct timespec ts;
  if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0) return 0;
  return (int64_t)ts.tv_sec * 1000 + ts.tv_nsec / 1000000;
#else
  return 0;
#endif
}
MOONBIT_FFI_EXPORT int32_t mn_is_linux(void) {
#ifdef __linux__
  return 1;
#else
  return 0;
#endif
}

/* Prefix only the FFI result with signed LE i32; actual packets remain native endian. */
static moonbit_bytes_t frame(int32_t status, const void *data, int n) {
  moonbit_bytes_t out = moonbit_make_bytes_raw(4 + n);
  uint32_t bits = (uint32_t)status;
  for (int i = 0; i < 4; i++) out[i] = (uint8_t)(bits >> (8*i));
  if (n) memcpy(out + 4, data, (size_t)n);
  return out;
}

MOONBIT_FFI_EXPORT int32_t mn_send(void *ptr, moonbit_bytes_t data) {
#ifdef __linux__
  mn_handle *h = ptr;
  if (h->fd < 0) return -EBADF;
  struct sockaddr_nl kernel = {0}; kernel.nl_family = AF_NETLINK;
  ssize_t n;
  do { n = sendto(h->fd, data, Moonbit_array_length(data), 0,
                  (struct sockaddr *)&kernel, sizeof(kernel)); } while (n < 0 && errno == EINTR);
  return n < 0 ? -errno : (int32_t)n;
#else
  (void)ptr; (void)data; return -95;
#endif
}

MOONBIT_FFI_EXPORT moonbit_bytes_t mn_receive(void *ptr, int32_t timeout) {
#ifdef __linux__
  mn_handle *h = ptr;
  if (h->fd < 0) return frame(-EBADF, NULL, 0);
  struct pollfd p = {h->fd, POLLIN, 0};
  int64_t deadline = mn_monotonic() + timeout;
  int ready;
  for (;;) {
    int64_t remaining = deadline - mn_monotonic();
    if (remaining < 0) remaining = 0;
    ready = poll(&p, 1, (int)remaining);
    if (ready >= 0 || errno != EINTR) break;
    if (mn_monotonic() >= deadline) return frame(0, NULL, 0);
  }
  if (ready == 0) return frame(0, NULL, 0);
  if (ready < 0) return frame(-errno, NULL, 0);
  if (p.revents & POLLNVAL) return frame(-EBADF, NULL, 0);
  /* PEEK|TRUNC obtains exact datagram size; never silently parse truncated data. */
  ssize_t size = recv(h->fd, NULL, 0, MSG_PEEK | MSG_TRUNC | MSG_DONTWAIT);
  if (size < 0) return frame(-errno, NULL, 0);
  if (size > 1048576) {
    char discard;
    recv(h->fd, &discard, 1, MSG_TRUNC | MSG_DONTWAIT);
    return frame(-EMSGSIZE, NULL, 0);
  }
  char *buffer = malloc(size ? (size_t)size : 1);
  if (!buffer) return frame(-ENOMEM, NULL, 0);
  struct sockaddr_nl peer = {0};
  struct iovec iov = {buffer, (size_t)size};
  struct msghdr msg = {0};
  msg.msg_name = &peer; msg.msg_namelen = sizeof(peer); msg.msg_iov = &iov; msg.msg_iovlen = 1;
  ssize_t n = recvmsg(h->fd, &msg, MSG_DONTWAIT);
  int status = n < 0 ? -errno : (int)n;
  if (n >= 0 && ((msg.msg_flags & MSG_TRUNC) || n != size)) status = -EMSGSIZE;
  if (n >= 0 && (msg.msg_namelen < sizeof(peer) || peer.nl_family != AF_NETLINK || peer.nl_pid != 0)) status = -EPROTO;
  moonbit_bytes_t result = status < 0 ? frame(status, NULL, 0) : frame(status, buffer, status);
  free(buffer);
  return result;
#else
  (void)ptr; (void)timeout; return frame(-95, NULL, 0);
#endif
}

MOONBIT_FFI_EXPORT moonbit_bytes_t mn_read_file(moonbit_bytes_t path) {
  FILE *f = fopen((const char *)path, "rb");
  if (!f) return frame(-errno, NULL, 0);
  if (fseek(f, 0, SEEK_END) != 0) { int e = errno; fclose(f); return frame(-e, NULL, 0); }
  long size = ftell(f);
  if (size < 0 || size > 33554432) { fclose(f); return frame(-27, NULL, 0); }
  rewind(f);
  char *buffer = malloc(size ? (size_t)size : 1);
  if (!buffer) { fclose(f); return frame(-12, NULL, 0); }
  size_t n = fread(buffer, 1, (size_t)size, f);
  int ok = n == (size_t)size && !ferror(f);
  fclose(f);
  moonbit_bytes_t result = ok ? frame((int)n, buffer, (int)n) : frame(-5, NULL, 0);
  free(buffer); return result;
}
MOONBIT_FFI_EXPORT int32_t mn_write_file(moonbit_bytes_t path, moonbit_bytes_t data, int32_t append) {
  FILE *f = fopen((const char *)path, append ? "ab" : "wb");
  if (!f) return -errno;
  size_t size = (size_t)Moonbit_array_length(data);
  int ok = fwrite(data, 1, size, f) == size;
  if (fclose(f) != 0) ok = 0;
  return ok ? 0 : -5;
}
MOONBIT_FFI_EXPORT void mn_exit(int32_t code) { exit(code); }
MOONBIT_FFI_EXPORT void mn_stderr(moonbit_bytes_t data) {
  fwrite(data, 1, (size_t)Moonbit_array_length(data), stderr);
  fflush(stderr);
}
MOONBIT_FFI_EXPORT void mn_flush(void) { fflush(stdout); }
