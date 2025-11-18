import 'package:flutter/material.dart';
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';

/// Demo page showing math formula rendering
class MathDemo extends StatelessWidget {
  const MathDemo({
    super.key,
    this.styleSheet,
  });

  final MarkdownStyleSheet? styleSheet;

  static const String _mathContent = '''
# LaTeX Math Formulas

## Inline Math

The **Pythagorean theorem** is expressed as \$a^2 + b^2 = c^2\$.

The **quadratic formula** is \$x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}\$.

Einstein's famous equation: \$E = mc^2\$.

## Display Math (Block)

The **Euler's identity** is considered one of the most beautiful equations:

\$\$
e^{i\\pi} + 1 = 0
\$\$

The **Schrödinger equation** in quantum mechanics:

\$\$
i\\hbar\\frac{\\partial}{\\partial t}\\Psi(\\mathbf{r},t) = \\hat{H}\\Psi(\\mathbf{r},t)
\$\$

The **Maxwell's equations** (simplified):

\$\$
\\nabla \\cdot \\mathbf{E} = \\frac{\\rho}{\\epsilon_0}
\$\$

\$\$
\\nabla \\times \\mathbf{E} = -\\frac{\\partial \\mathbf{B}}{\\partial t}
\$\$

## Summation and Integration

The **sum of first n natural numbers**:

\$\$
\\sum_{i=1}^{n} i = \\frac{n(n+1)}{2}
\$\$

The **Gaussian integral**:

\$\$
\\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}
\$\$

## Matrices

A simple **2x2 matrix**:

\$\$
\\begin{pmatrix}
a & b \\\\
c & d
\\end{pmatrix}
\$\$

## Calculus

The **fundamental theorem of calculus**:

\$\$
\\int_a^b f'(x) dx = f(b) - f(a)
\$\$

Inline derivatives: The derivative of \$x^n\$ is \$nx^{n-1}\$.

## Complex Expressions

The **binomial theorem**:

\$\$
(x + y)^n = \\sum_{k=0}^{n} \\binom{n}{k} x^{n-k} y^k
\$\$

---

**Note:** All formulas are rendered using LaTeX syntax with flutter_math_fork.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Formula Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SmoothMarkdown(
          data: _mathContent,
          styleSheet: styleSheet,
        ),
      ),
    );
  }
}
