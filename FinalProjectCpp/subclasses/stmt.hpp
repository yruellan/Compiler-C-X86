#pragma once
#include "../token.hpp"

class Stmt : public Token {
    public:
        Stmt(TokenType t ) : Token(t) {}
        virtual void print(string indent = "") override;
};


class Sscope : public Stmt {
    public:
        vector<Stmt*> body;
        Sscope() : Stmt(SCOPE){
            body = vector<Stmt*>();
        };
        Sscope(vector<Stmt*> body) : Stmt(SCOPE){
            this->body = body;
        };
        void print(string indent = "") override;

        unordered_map<string, Variable> vars;
        void init_var(string var_name, bool is_arg);
        vector<Tk> children() override {
            vector<Tk> res;
            for (auto v : body) {
                res.push_back((Tk) v);
            }
            return res;
        }

    private:
        int var_offset;
        int arg_offset;
};

class Sreturn : public Stmt {
    public:
        Expr* value;
        Sreturn() : Stmt(RETURN){
            value = nullptr;
        };
        Sreturn(Expr* value) : Stmt(RETURN){
            this->value = value;
        };
        void print(string indent = "") override;

        void on_exit() override;
        vector<Tk> children() override {
            return {(Tk)value};
        }
};

class Sfor : public Stmt {
    public:
        Stmt* init;
        Expr* condition;
        Stmt* increment;
        Stmt* body;
        Sfor() : Stmt(FOR){
            init = nullptr;
            condition = nullptr;
            increment = nullptr;
            body = nullptr;
        };
        Sfor(Stmt* init, Expr* condition, Stmt* increment, Stmt* body)
        : Stmt(FOR){
            this->init = init;
            this->condition = condition;
            this->increment = increment;
            this->body = body;
        };
        void print(string indent = "") override;
        vector<Tk> children() override {
            return {(Tk)init, (Tk)condition, (Tk)increment, (Tk)body};
        }
        void on_enter() override;
};

class Swhile : public Stmt {
    public:
        Expr* condition;
        Stmt* body;
        Swhile() : Stmt(WHILE){
            condition = nullptr;
            body = nullptr;
        };
        Swhile(Expr* condition, Stmt* body) : Stmt(WHILE){
            this->condition = condition;
            this->body = body;
        };
        void print(string indent = "") override;
        vector<Tk> children() override {
            return {(Tk)condition, (Tk)body};
        }
        void on_enter() override;
};

class SvarDef : public Stmt {
    public:
        string type;
        string name;
        Expr* value;
        SvarDef() : Stmt(VAR_DEF){
            type = "";
            name = "";
            value = nullptr;
        };
        SvarDef(string type, string name, Expr* value) : Stmt(VAR_DEF){
            this->type = type;
            this->name = name;
            this->value = value;
        };
        void print(string indent = "") override;
        void on_exit() override;
        vector<Tk> children() override {
            if (value == nullptr) return {};
            return {(Tk)value};
        }
};

class SvarSet : public Stmt {
    public:
        LeftValue* left_value;
        string op;
        Expr* value;
        SvarSet() : Stmt(VAR_SET){
            left_value = nullptr;
            op = "";
            value = nullptr;
        };
        SvarSet(LeftValue* left_value, string op, Expr* value) : Stmt(VAR_SET){
            this->left_value = left_value;
            this->op = op;
            this->value = value;
        };
        void print(string indent = "") override;
        void on_exit() override;
        vector<Tk> children() override {
            return {(Tk)left_value, (Tk)value};
        }
};

class Sexpr : public Stmt {
    public:
        Expr* value;
        Sexpr() : Stmt(EXPR_STMT){
            value = nullptr;
        };
        Sexpr(Expr* value) : Stmt(EXPR_STMT){
            this->value = value;
        };
        void print(string indent = "") override;
        vector<Tk> children() override {
            return {(Tk)value};
        }
};

class Sif : public Stmt {
    public:
        Expr* condition;
        Stmt* body;
        Sif() : Stmt(IF){
            condition = nullptr;
            body = nullptr;
        };
        Sif(Expr* condition, Stmt* body) : Stmt(IF){
            this->condition = condition;
            this->body = body;
        };
        void print(string indent = "") override;
        vector<Tk> children() override {
            return {(Tk)condition, (Tk)body};
        }
        void on_enter() override;
};

class SifElse : public Stmt {
    public:
        Expr* condition;
        Stmt* body_if;
        Stmt* body_else;
        SifElse() : Stmt(IF_ELSE){
            condition = nullptr;
            body_if = nullptr;
            body_else = nullptr;
        };
        SifElse(Expr* condition, Stmt* body_if, Stmt* body_else) : Stmt(IF_ELSE){
            this->condition = condition;
            this->body_if = body_if;
            this->body_else = body_else;
        };
        void print(string indent = "") override;
        vector<Tk> children() override {
            return {(Tk)condition, (Tk)body_if, (Tk)body_else};
        }
        void on_enter() override;
};
