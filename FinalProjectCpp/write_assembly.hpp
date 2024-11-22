#pragma once

#include <string>
#include <fstream>
#include <unordered_map>

#include "define.hpp"

void init();
void w_init_template();
void w_init_f(std::string str); // init a function
void w_print(std::string str);
void w_init_var();
void w_init_global_var(std::string str);
void w_set_var(int val);
void w_set_global_var(std::string str);
void w_get_var(int val);
void w_push_cst(int val);
void w_push_local_var(int val);
void w_push_global_var(std::string str);
void w_call_function(std::string str);
void w_call_read(std::string str, int val, bool is_global);
void w_op(std::string op_name);
void w_ret(bool main);
void end();
