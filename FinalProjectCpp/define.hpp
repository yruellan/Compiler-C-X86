#pragma once
#include <string>
#include <iostream>
#include <fstream>
#include <unordered_map>

using namespace std;

inline int verbose ;
inline string file_name;

#define v_cout if (verbose>=1) cout

#define ERROR(msg) throw std::invalid_argument( msg )

#define SIZE 8
#define COMMENT "#"
#define GLOBAL "__root__"
#define MAIN "main"
#define PRINT "print"
#define SCAN "scan"
#define READ "read"
#define TEMPLATE "FinalProjectCpp/template.s"