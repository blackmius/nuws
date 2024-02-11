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

{.push header: "./uWebSockets/capi/libuwebsockets.h".}
type
  us_socket_context_options_t {.importc: "struct $1", } = object
  us_listen_socket_t {.importc: "struct $1".} = ptr object
  uws_app_t {.importc} = ptr object
  uws_res_t {.importc.} = ptr object
  uws_req_t {.importc.} = ptr object
  uws_app_listen_config_t {.importc.} = ptr object
  uws_method_handler {.importc.} = proc(response: uws_res_t, request: uws_req_t, user_data: pointer) {.nimcall.}
  uws_listen_handler {.importc.} = proc(listen_socket: us_listen_socket_t, config: uws_app_listen_config_t, user_data: pointer) {.nimcall.}
  uws_listen_domain_handler {.importc.} = proc(listen_socket: us_listen_socket_t, domain: cstring, domain_length: cint, options: int, user_data: pointer) {.nimcall.}
  uws_missing_server_handler {.importc.} = proc(hostname: cstring, hostname_length: cint, user_data: pointer) {.nimcall.}
  uws_filter_handler {.importc.} = proc(response: uws_res_t, ok: int, user_data: pointer) {.nimcall.}
  uws_get_headers_server_handler {.importc.} = proc(header_name: cstring, header_name_size: cuint, header_value: cstring, header_value_size: cuint, user_data: pointer) {.nimcall.}

  uws_opcode_t {.importc.} = enum
    CONTINUATION = 0,
    TEXT = 1,
    BINARY = 2,
    CLOSE = 8,
    PING = 9,
    PONG = 10

  uws_socket_behavior_t {.importc.} = object
  uws_websocket_t {.importc.} = ptr object
  uws_socket_context_t {.importc.} = object
  uws_sendstatus_t {.importc.} = object
  uws_try_end_result_t {.importc.} = object
  us_loop_t {.importc.} = ptr object
# Basic HTTP
proc uws_create_app(ssl: int, options: us_socket_context_options_t): uws_app_t {.importc.}
proc uws_app_destroy(ssl: int, app: uws_app_t) {.importc.}
proc uws_app_get(ssl: int, app: uws_app_t, pattern: cstring, handler: uws_method_handler, user_data: pointer) {.importc.}
proc uws_app_post(ssl: int, app: uws_app_t, pattern: cstring, handler: uws_method_handler, user_data: pointer) {.importc.}
proc uws_app_options(ssl: int, app: uws_app_t, pattern: cstring, handler: uws_method_handler, user_data: pointer) {.importc.}
proc uws_app_delete(ssl: int, app: uws_app_t, pattern: cstring, handler: uws_method_handler, user_data: pointer) {.importc.}
proc uws_app_patch(ssl: int, app: uws_app_t, pattern: cstring, handler: uws_method_handler, user_data: pointer) {.importc.}
proc uws_app_put(ssl: int, app: uws_app_t, pattern: cstring, handler: uws_method_handler, user_data: pointer) {.importc.}
proc uws_app_head(ssl: int, app: uws_app_t, pattern: cstring, handler: uws_method_handler, user_data: pointer) {.importc.}
proc uws_app_connect(ssl: int, app: uws_app_t, pattern: cstring, handler: uws_method_handler, user_data: pointer) {.importc.}
proc uws_app_trace(ssl: int, app: uws_app_t, pattern: cstring, handler: uws_method_handler, user_data: pointer) {.importc.}
proc uws_app_any(ssl: int, app: uws_app_t, pattern: cstring, handler: uws_method_handler, user_data: pointer) {.importc.}

proc uws_app_run(ssl: int, app: uws_app_t) {.importc.}

proc uws_app_listen(ssl: int, app: uws_app_t, port: int, handler: uws_listen_handler, user_data: pointer) {.importc.}
proc uws_app_listen_with_config(ssl: int, app: uws_app_t, config: uws_app_listen_config_t, handler: uws_listen_handler, user_data: pointer) {.importc.}
proc uws_app_listen_domain(ssl: int, app: uws_app_t, domain: cstring, domain_length: cuint, handler: uws_listen_domain_handler, user_data: pointer) {.importc.}
proc uws_app_listen_domain_with_options(ssl: int, app: uws_app_t, domain: cstring, domain_length: cuint, options: int, handler: uws_listen_domain_handler, user_data: pointer) {.importc.}
proc uws_app_domain(ssl: int, app: uws_app_t, server_name: cstring, server_name_length: cuint) {.importc.}
proc uws_app_close(ssl: int, app: uws_app_t) {.importc.}

proc uws_constructor_failed(ssl: int, app: uws_app_t): bool {.importc.}
proc uws_num_subscribers(ssl: int, app: uws_app_t, topic: cstring, topic_length: cuint): cuint {.importc.}
proc uws_publish(ssl: int, app: uws_app_t, topic: cstring, topic_length: cuint, message: cstring, message_length: cuint, opcode: uws_opcode_t, compress: bool): bool {.importc.}
proc uws_get_native_handle(ssl: int, app: uws_app_t): pointer {.importc.}
proc uws_remove_server_name(ssl: int, app: uws_app_t, hostname_pattern: cstring, hostname_pattern_length: cuint) {.importc.}
proc uws_add_server_name(ssl: int, app: uws_app_t, hostname_pattern: cstring, hostname_pattern_length: cuint) {.importc.}
proc uws_add_server_name_with_options(ssl: int, app: uws_app_t, hostname_pattern: cstring, hostname_pattern_length: cuint, options: us_socket_context_options_t) {.importc.}
proc uws_missing_server_name(ssl: int, app: uws_app_t, handler: uws_missing_server_handler, user_data: pointer) {.importc.}
proc uws_filter(ssl: int, app: uws_app_t, handler: uws_filter_handler, user_data: pointer) {.importc.}

# WebSocket
proc uws_ws(ssl: int, app: uws_app_t, pattern: cstring, behavior: uws_socket_behavior_t, user_data: pointer) {.importc.}
proc uws_ws_get_user_data(ssl: int, ws: uws_websocket_t): pointer {.importc.}
proc uws_ws_close(ssl: int, ws: uws_websocket_t) {.importc.}
proc uws_ws_send(ssl: int, ws: uws_websocket_t, message: cstring, length: cuint, opcode: uws_opcode_t): uws_sendstatus_t {.importc.}
proc uws_ws_send_with_options(ssl: int, ws: uws_websocket_t, message: cstring, length: cuint, opcode: uws_opcode_t, compress: bool, fin: bool): uws_sendstatus_t {.importc.}
proc uws_ws_send_fragment(ssl: int, ws: uws_websocket_t, message: cstring, length: cuint, compress: bool): uws_sendstatus_t {.importc.}
proc uws_ws_send_first_fragment(ssl: int, ws: uws_websocket_t, message: cstring, length: cuint, compress: bool): uws_sendstatus_t {.importc.}
proc uws_ws_send_first_fragment_with_opcode(ssl: int, ws: uws_websocket_t, message: cstring, length: cuint, opcode: uws_opcode_t, compress: bool): uws_sendstatus_t {.importc.}
proc uws_ws_send_last_fragment(ssl: int, ws: uws_websocket_t, message: cstring, length: cuint, compress: bool): uws_sendstatus_t {.importc.}
proc uws_ws_end(ssl: int, ws: uws_websocket_t, code: int, message: cstring, length: cuint) {.importc.}
proc uws_ws_cork(ssl: int, ws: uws_websocket_t, code: int, handler: proc(user_data: pointer) {.nimcall.}, user_data: pointer) {.importc.}

proc uws_ws_subscribe(ssl: int, ws: uws_websocket_t, topic: cstring, length: cuint): bool {.importc.}
proc uws_ws_unsubscribe(ssl: int, ws: uws_websocket_t, topic: cstring, length: cuint): bool {.importc.}
proc uws_ws_is_subscribed(ssl: int, ws: uws_websocket_t, topic: cstring, length: cuint): bool {.importc.}
proc uws_ws_iterate_topics(ssl: int, ws: uws_websocket_t, callback: proc(topic: cstring, length: cuint, user_data: pointer) {.nimcall.}, user_data: pointer) {.importc.}

proc uws_ws_publish(ssl: int, ws: uws_websocket_t, topic: cstring, topic_length: cuint, message: cstring, message_length: cuint): bool {.importc.}
proc uws_ws_publish_with_options(ssl: int, ws: uws_websocket_t, topic: cstring, topic_length: cuint, message: cstring, message_length: cuint, opcode: uws_opcode_t, compress: bool): bool {.importc.}
proc uws_ws_get_buffered_amount(ssl: int, ws: uws_websocket_t): cuint {.importc.}
proc uws_ws_get_remote_address(ssl: int, ws: uws_websocket_t, dest: pointer): cuint {.importc.}
proc uws_ws_get_remote_address_as_text(ssl: int, ws: uws_websocket_t, dest: pointer): cuint {.importc.}

# Response
proc uws_res_end(ssl: int, res: uws_res_t, data: cstring, length: cuint, close_connection: bool) {.importc.}
proc uws_res_try_end(ssl: int, res: uws_res_t, data: cstring, length: cuint, total_size: cuint, close_connection: bool): uws_try_end_result_t {.importc.}
proc uws_res_cork(ssl: int, res: uws_res_t, callback: proc(res: uws_res_t, user_data: pointer) {.nimcall.}, user_data: pointer) {.importc.}
proc uws_res_pause(ssl: int, res: uws_res_t) {.importc.}
proc uws_res_resume(ssl: int, res: uws_res_t) {.importc.}
proc uws_res_write_continue(ssl: int, res: uws_res_t) {.importc.}
proc uws_res_write_status(ssl: int, res: uws_res_t, status: cstring, length: cuint) {.importc.}
proc uws_res_write_header(ssl: int, res: uws_res_t, key: cstring, key_length: cuint, value: cstring, value_length: cuint) {.importc.}

proc uws_res_write_header_int(ssl: int, res: uws_res_t, key: cstring, key_length: cuint, value: cuint) {.importc.}
proc uws_res_end_without_body(ssl: int, res: uws_res_t, close_connection: bool) {.importc.}
proc uws_res_write(ssl: int, res: uws_res_t, data: cstring, length: cuint): bool {.importc.}
proc uws_res_get_write_offset(ssl: int, res: uws_res_t): cuint {.importc.}
proc uws_res_override_write_offset(ssl: int, res: uws_res_t, offset: cuint) {.importc.}
proc uws_res_has_responded(ssl: int, res: uws_res_t): bool {.importc.}

proc uws_res_on_writable(ssl: int, res: uws_res_t, handler: proc(res: uws_res_t, ok: cuint, optional_data: pointer) {.nimcall.}, user_data: pointer) {.importc.}
proc uws_res_on_aborted(ssl: int, res: uws_res_t, handler: proc(res: uws_res_t, optional_data: pointer) {.nimcall.}, optional_data: pointer) {.importc.}
proc uws_res_on_data(ssl: int, res: uws_res_t, handler: proc(res: uws_res_t, chunk: cstring, chunk_length: cuint, is_end: bool, optional_data: pointer) {.nimcall.}, optional_data: pointer) {.importc.}
proc uws_res_upgrade(ssl: int, res: uws_res_t, data: pointer, sec_web_socket_key: cstring, sec_web_socket_key_length: cuint, sec_web_socket_protocol: cstring, sec_web_socket_protocol_length: cuint, sec_web_socket_extensions: cstring, sec_web_socket_extensions_length: cuint, ws: uws_socket_context_t) {.importc.}
proc uws_res_get_remote_address(ssl: int, res: uws_res_t, dest: pointer): cuint {.importc.}
proc uws_res_get_remote_address_as_text(ssl: int, res: uws_res_t, dest: pointer): cuint {.importc.}

when defined(UWS_WITH_PROXY):
  proc uws_res_get_proxied_remote_address(ssl: int, res: uws_res_t, dest: pointer): cuint {.importc.}
  proc uws_res_get_proxied_remote_address_as_text(ssl: int, res: uws_res_t, dest: pointer): cuint {.importc.}

proc uws_res_get_native_handle(ssl: int, res: uws_res_t): pointer {.importc.}

# Request
proc uws_req_is_ancient(req: uws_req_t): bool {.importc.}
proc uws_req_get_yield(req: uws_req_t): bool {.importc.}
proc uws_req_set_yield(req: uws_req_t, `yield`: bool) {.importc.}
proc uws_req_get_url(req: uws_req_t, dest: pointer): cuint {.importc.}
proc uws_req_get_full_url(req: uws_req_t, dest: pointer): cuint {.importc.}
proc uws_req_get_method(req: uws_req_t, dest: pointer): cuint {.importc.}
proc uws_req_get_case_sensitive_method(req: uws_req_t, dest: pointer): cuint {.importc.}

proc uws_req_get_header(req: uws_req_t, lower_case_header: cstring, lower_case_header_length: cuint, dest: pointer): cuint {.importc.}
proc uws_req_for_each_header(req: uws_req_t, handler: uws_get_headers_server_handler, user_data: pointer) {.importc.}
proc uws_req_get_query(req: uws_req_t, key: cstring, key_length: cuint, dest: pointer): cuint {.importc.}
proc uws_req_get_parameter(req: uws_req_t, index: cstring, dest: pointer): cuint {.importc.}

proc uws_get_loop(): us_loop_t {.importc.}
proc uws_get_loop_with_native(existing_native_loop: pointer): us_loop_t {.importc.}
proc uws_loop_defer(loop: us_loop_t, cb: proc(user_data: pointer), user_data: pointer) {.importc.}
{.pop.}

# NIM api

type
  App = object
    handle: uws_app_t
    ssl: int

  Options = object

  Res = object
    handle: uws_res_t
    ssl: int
  Req = object
    handle: uws_req_t

proc initApp(options: Options): App =
  result.handle = uws_create_app(0, us_socket_context_options_t())

proc initSSLApp(options: Options): App =
  result.ssl = 1
  result.handle = uws_create_app(1, us_socket_context_options_t())

template addMethod(name: untyped) =
  proc name(app: App, pattern: string, cb: proc(res: Res, req: Req)): App {.discardable.} =
    proc rawCb(res: uws_res_t, req: uws_req_t) =
      cb(Res(ssl: app.ssl, handle: res), Req(handle: req))
    `uws_app name`(app.ssl, app.handle, pattern, cast[uws_method_handler](rawCb.rawProc), rawCb.rawEnv)
    return app

addMethod(get)
addMethod(post)
addMethod(options)
addMethod(delete)
addMethod(patch)
addMethod(put)
addMethod(head)
addMethod(connect)
addMethod(trace)
addMethod(any)

proc listen(app: App, port: int, cb: proc(listen_socket: us_listen_socket_t, config: uws_app_listen_config_t)): App {.discardable.} =
  uws_app_listen(app.ssl, app.handle, port, cast[uws_listen_handler](cb.rawProc), cb.rawEnv)
  return app

proc run(app: App) =
  uws_app_run(app.ssl, app.handle)

proc `end`(res: Res, data: string, close: bool = true) =
  uws_res_end(res.ssl, res.handle, data, data.len.cuint, close)

let app = initApp(Options())

app.get("/*", proc(res: Res, req: Req) =
  res.`end`("Hello\n")
).listen(3000, proc(listen_socket: us_listen_socket_t, config: uws_app_listen_config_t) =
  echo "start listening"
).run()