#include "../token.hpp"
#include "../context.hpp"
#include "../write_assembly.hpp"

#include "../subclasses/arg.hpp"
#include "../subclasses/expr.hpp"
#include "../subclasses/gstmt.hpp"
#include "../subclasses/left_val.hpp"
#include "../subclasses/litteral.hpp"
#include "../subclasses/root.hpp"
#include "../subclasses/stmt.hpp"


void GVarDef::on_exit(){
    

    int size = contexts[GLOBAL].init_var(name, type_size(type), ladder, false);
    string value = "" ;

    set_section("data");
    add_line(name + ":", false);

    if (this->value == nullptr)
        add_line(".zero " + std::to_string(size));

    else if (this->value->tk_type == LITTERAL_INT)
        add_line(".quad " + to_string(((Int*)this->value)->value) );

    else if (this->value->tk_type == LITTERAL_BOOL)
    // it works with a quad for now
        add_line(".quad " + to_string(((Bool*)this->value)->value) );

    else if (this->value->tk_type == LITTERAL_CHAR)
        add_line(".short " + to_string(((Char*)this->value)->value) );

    else if (this->value->tk_type == LITTERAL_STRING){
        String* str = (String*)this->value;
        int len = size - str->length;
        if (len < 0) ERROR("String too long");
        string s = ".asciz \"" + str->value;
        for (int i = 0; i < len; i++) s += "\\0";
        add_line( s + "\"" );
    
    } else {
        add_line(".zero " + std::to_string(size));
        // TODO : init value in __cxx_global_var_init
        v_cout << " err : " << name << ", " << this->value->tk_type << endl;
        ERROR("Global variable inizialization not yet implemented for non litteral values : " + name);
    }

    // add_line();

}
void SvarDef::on_enter(){
    int size = contexts[called_contexts.back()].init_var(name, type_size(type), ladder, false);

    add_line("init local variable", true, true);
    add_line("sub $" + to_string(size) + ", %rsp");
}
void SvarDef::on_exit(){
    int size = contexts[called_contexts.back()].vars[name].full_size; 
    int address = contexts[called_contexts.back()].var_offset;

    if (value != nullptr && value->tk_type == LITTERAL_STRING){
        String* str = (String*)this->value;
        int len = size - str->length;
        if (len < 0) ERROR("String too long");
        for (int i = 0; i < size ; i++){
            string s = (i < str->length) ? std::to_string(str->value[i]) : "\\0";
            add_line("movb $" + s + ", " + std::to_string(address + str->length - i) + "(%rbp)");
        }
    } else if (value != nullptr){
        add_line("pop " + contexts[called_contexts.back()].vars[name].get_adress());
    }
    add_line();
}


void w_init_global_var(string str, int size, string value){
    // set_section("bss");
    // add_line("init global variable " + str, true, true);
    // add_line(".align " + std::to_string(size));
    // add_line(".type " + str + ", @object");
    // add_line(".size " + str + ", " + std::to_string(size));
    // add_line(str + ":", false);
    // add_line(".zero " + std::to_string(size));
    // add_line();
}



void w_set_var(string add, string op){
    // set local or global variable with the last value in the stack

    add_line("set local variable : "+op, true, true);
    if        (op == "=") {
        add_line("pop " + add);
    } else if (op == "+=") {
        add_line("pop %rax");
        add_line("add %rax, " + add);
    } else if (op == "*=") {
        add_line("pop %rax");
        add_line("mov "+add + ", %rbx");
        add_line("imul %rax, %rbx");
        add_line("mov %rbx, " + add);
    } else if (op == "/=") {
        add_line("pop %rbx");
        add_line("mov " + add +", %rax");
        add_line("xor %rdx, %rdx");
        add_line("idivq %rbx");
        add_line("mov %rax, "+add);
    } else if (op == "%=") {
        add_line("pop %rbx");
        add_line("mov "+add+", %rax");
        add_line("xor %rdx, %rdx");
        add_line("idivq %rbx");
        add_line("mov %rdx, "+add);
    } else ERROR("op " + op + " is not implemented");
    add_line();
}

void w_set_var(string op){
    // set local or global variable with the last value in the stack

    add_line("set local variable : "+op, true, true);
    if        (op == "=") {
        add_line("pop %rbx");
        add_line("pop %rax");
        add_line("mov %rbx, (%rax)");

    } else if (op == "+=") {
        add_line("pop %rbx");
        add_line("pop %rax");
        add_line("add %rbx, (%rax)");
    } else if (op == "-=") {
        add_line("pop %rbx");
        add_line("pop %rax");
        add_line("sub %rbx, (%rax)");
    } else if (op == "*=") {
        add_line("pop %rbx");
        add_line("pop %rax");
        add_line("imul (%rax), %rbx");
        add_line("mov %rbx, (%rax)");
    } else if (op == "/=") {
        add_line("pop %rbx");
        add_line("pop %rcx");
        add_line("mov (%rcx), %rax");
        add_line("cqo");
        add_line("idiv %rbx");
        add_line("mov %rax, (%rcx)");
    } else if (op == "%=") {
        add_line("pop %rbx");
        add_line("pop %rcx");
        add_line("mov (%rcx), %rax");
        add_line("cqo");
        add_line("idiv %rbx");
        add_line("mov %rdx, (%rcx)");
    } else ERROR("op " + op + " is not implemented");
    add_line();
}
