import strutils, ospaths
from os import DirSep, walkFiles

const srcPath = currentSourcePath.rsplit(DirSep, 1)[0] &
  "/uWebSockets/"
{.passC: "-I\"" & srcPath & "uSockets/src\"".}
{.passC: "-I\"" & srcPath & "src\"".}
{.localPassC: "-O3 -Wpedantic -Wall -Wextra -Wsign-conversion -Wconversion".}
{.passC: "-DUWS_WITH_PROXY".}
{.passC: "-DLIBUS_USE_OPENSSL".}
{.passC: "-DLIBUS_USE_LIBUV".}
{.localPassC: "-fPIC"}
{.passL: "-lz -luv -lssl -lcrypto -lstdc++"}
{.compile: srcPath & "uSockets/src/eventing/epoll_kqueue.c".}
{.compile: srcPath & "uSockets/src/eventing/gcd.c".}
{.compile: srcPath & "uSockets/src/eventing/libuv.c".}

{.compile: srcPath & "uSockets/src/socket.c".}
{.compile: srcPath & "uSockets/src/udp.c".}
{.compile: srcPath & "uSockets/src/quic.c".}
{.compile: srcPath & "uSockets/src/loop.c".}
{.compile: srcPath & "uSockets/src/context.c".}
{.compile: srcPath & "uSockets/src/bsd.c".}

{.compile: srcPath & "uSockets/src/crypto/openssl.c".}
{.compile: srcPath & "uSockets/src/crypto/sni_tree.cpp".}

{.compile: srcPath & "capi/libuwebsockets.cpp".}

type
  us_socket_context_options_t {.importc: "struct $1", header: "./uWebSockets/capi/libuwebsockets.h"} = object
  us_listen_socket_t {.importc: "struct $1", header: "./uWebSockets/capi/libuwebsockets.h".} = ptr object
  uws_app_t {.importc, header: "./uWebSockets/capi/libuwebsockets.h"} = ptr object
  uws_res_t {.importc, header: "./uWebSockets/capi/libuwebsockets.h".} = ptr object
  uws_req_t {.importc, header: "./uWebSockets/capi/libuwebsockets.h".} = ptr object
  uws_app_listen_config_t {.importc, header: "./uWebSockets/capi/libuwebsockets.h".} = ptr object
  uws_method_handler {.importc, header: "./uWebSockets/capi/libuwebsockets.h".} = proc(response: uws_res_t, request: uws_req_t, user_data: pointer) {.nimcall.}
  uws_listen_handler {.importc, header: "./uWebSockets/capi/libuwebsockets.h".} = proc(listen_socket: us_listen_socket_t, config: uws_app_listen_config_t, user_data: pointer) {.nimcall.}

proc uws_create_app(ssl: int, options: us_socket_context_options_t): uws_app_t {.importc, header: "./uWebSockets/capi/libuwebsockets.h".}
proc uws_app_get(ssl: int, app: uws_app_t, pattern: cstring, handler: uws_method_handler, user_data: pointer) {.importc, header: "./uWebSockets/capi/libuwebsockets.h".}
proc uws_app_listen(ssl: int, app: uws_app_t, port: int, handler: uws_listen_handler, user_data: pointer) {.importc, header: "./uWebSockets/capi/libuwebsockets.h".}
proc uws_app_run(ssl: int, app: uws_app_t) {.importc, header: "./uWebSockets/capi/libuwebsockets.h".}

proc uws_res_end(ssl: int, res: uws_res_t, data: cstring, length: int, close_connection: bool) {.importc, header: "./uWebSockets/capi/libuwebsockets.h".}


let app = uws_create_app(0, us_socket_context_options_t())
uws_app_get(0, app, "/*", proc(res: uws_res_t, req: uws_req_t, user_data: pointer) =
  uws_res_end(0, res, "hello\n", 6, true)
, nil)
uws_app_listen(0, app, 3000, proc(listen_socket: us_listen_socket_t, config: uws_app_listen_config_t, user_data: pointer) =
  echo "start listening"
, nil)
uws_app_run(0, app)