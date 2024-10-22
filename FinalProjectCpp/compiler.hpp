#pragma once
#include <string>
#include <vector>
#include <algorithm>

#include "token.hpp"

#include "subclasses/arg.hpp"
#include "subclasses/expr.hpp"
#include "subclasses/gstmt.hpp"
#include "subclasses/left_val.hpp"
#include "subclasses/litteral.hpp"
#include "subclasses/root.hpp"
#include "subclasses/stmt.hpp"

class Compiler {
    public:

        Compiler(Token* root) : root(root){};

        void run();

    private:
        Token* root;
        Token* actual_token;

        vector<Token*> called_tokens;
        vector<Token*> stack;
        
        void init_compiling();
        void reversed_children_push(); // into stack
        void push_called_token();
        void pop_called_token();
        void free_tokens(Token* token);

};