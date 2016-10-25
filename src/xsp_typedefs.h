#ifndef B_AST_XSP_TYPEDEFS_H_
#define B_AST_XSP_TYPEDEFS_H_

namespace PerlAST {
    namespace AST { }
}

// make the names available in a separate namespace, to avoid
// a lot of %name directives in XS++
namespace B {
    namespace AST {
        using namespace PerlAST::AST;
    }
}

namespace B {
    namespace AST {
        using namespace PerlAST;
    }
}

#endif
