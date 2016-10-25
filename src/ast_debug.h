#ifndef B_AST_DEBUG_H_
#define B_AST_DEBUG_H_

/* Set up debugging output to be compiled out without assertions */

#ifndef DEBUG_OUTPUT
#  define AST_DEBUGGING 0
#  define AST_DEBUG(s) ((void)(s))
#  define AST_DEBUG_1(s, par1) ((void)(s), (void)(par1))
#  define AST_DEBUG_2(s, par1, par2) ((void)(s), (void)(par1), (void)(par2))
#else
#  define AST_DEBUGGING 1
#  define AST_DEBUG(s) do { printf(s); fflush(stdout); } while(0)
#  define AST_DEBUG_1(s, par1) do { printf(s, par1); fflush(stdout); } while(0)
#  define AST_DEBUG_2(s, par1, par2) do { printf(s, par1, par2); fflush(stdout); } while(0)
#endif

#endif
