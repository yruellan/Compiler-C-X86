.section .data
int_fmt:
    .string "%d\n"           # Format string for printing integers
int_fmt_scan:
    .string "%d"

.section .text
.globl print
.extern printf               # Declare printf as an external function
.globl main

print_int:
        # Prologue
        push %rbp                
        mov %rsp, %rbp           
        
        # Pop the last element from the stack into rsi (argument for printf)
        mov 16(%rbp), %rsi                 
    
        # Align the stack for printf
        mov %rsp, %rax           
        and $15, %rax            
        jz .call_print_int     

        # align stack
        sub $8, %rsp  
    
.call_print_int:
        # Load the format string into rdi (first argument for printf)
        lea int_fmt(%rip), %rdi  
        mov $0, %rax             
    
        # Call printf
        call printf              

        # Epilogue
        mov %rbp, %rsp
        pop %rbp                   
        ret                      


scan:
        # Prologue
        push %rbp                
        mov %rsp, %rbp           
        
        # set space for an intern variable    
        sub $8, %rsp            
    
        # Align the stack for printf
        mov %rsp, %rax           
        and $15, %rax            
        jz .call_scanf

        # align stack
        sub $8, %rsp 
    
.call_scanf:
        # Load the format string into rdi (first argument for printf)
        # pushq $0
        movq $0, %rax             
        leaq (%rsp), %rsi
        leaq int_fmt_scan(%rip), %rdi  
    
        # Call printf
        call scanf
        
        # save value in rax
        mov (%rsp), %rax 

        # Epilogue
        mov %rbp, %rsp
        popq %rbp                   
        ret                      




