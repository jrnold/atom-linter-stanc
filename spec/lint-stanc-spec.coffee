linterStanc = require('../lib/main')

messages = [
  {
    message:
      """Model name=assign_real_to_int_model
      Input file=test-models/bad/assign_real_to_int.stan
      Output file=test-models/bad/assign_real_to_int.cpp

      SYNTAX ERROR, MESSAGE(S) FROM PARSER:

      base type mismatch in assignment; variable name = a, type = int; right-hand side type=real

      ERROR at line 11

        9:      real b;
       10:      b <- 3.2;
       11:      a <- b;
                    ^
       12:    }

      PARSER EXPECTED: <expression assignable to left-hand side>
      """
    'returns':
      'line': 11
      'col': 11
  }
  {
    message:
      """Model name=bad10_model
      Input file=test-models/bad/lang/bad10.stan
      Output file=test-models/bad/lang/bad10.cpp

      SYNTAX ERROR, MESSAGE(S) FROM PARSER:

      variable identifier (name) may not end in double underscore (__)
          found identifer=y__

      ERROR at line 2

        1:    data {
        2:       real y__;
                     ^
        3:    }

      PARSER EXPECTED: <identifier>
      """
    'returns':
      'line': 2
      'col':  12
  }
  {
    'message':
      """Model name=good_funs_model
      Input file=test-models/bad/lang/good_funs.stan
      Output file=test-models/bad/lang/good_funs.cpp
      """
    'returns': null
  }
  {
    'message':
      """Model name=bad11_model
      Input file=test-models/bad/lang/bad11.stan
      Output file=test-models/bad/lang/bad11.cpp

      SYNTAX ERROR, MESSAGE(S) FROM PARSER:

      integer parameters or transformed parameters are not allowed;  found declared type int, parameter name=theta
      Problem with declaration.

      ERROR at line 2

        1:    parameters {
        2:      int theta;
                         ^
        3:    }

      """
    'returns':
      'line': 2
      'col': 16
  }
  {
    'message':
      """
      Model name=err_expected_end_of_model_model
      Input file=test-models/bad/err-expected-end-of-model.stan
      Output file=test-models/bad/err-expected-end-of-model.cpp

      PARSER EXPECTED: whitespace to end of file.
      FOUND AT line 3:
      foo
      """
    'returns':
      'line': 3
      'col': 0
  }
  {
    'message':
      """
      Model name=err_expected_generated_model
      Input file=test-models/bad/err-expected-generated.stan
      Output file=test-models/bad/err-expected-generated.cpp

      SYNTAX ERROR, MESSAGE(S) FROM PARSER:


      ERROR at line 3

        1:    model {
        2:    }
        3:    generated {
                        ^
        4:    }

      PARSER EXPECTED: "quantities"
      """
    'returns':
      'line': 3
      'col': 15
  }
  {
    'message':
      """
      Model name=err_minus_types_model
      Input file=test-models/bad/err-minus-types.stan
      Output file=test-models/bad/err-minus-types.cpp

      SYNTAX ERROR, MESSAGE(S) FROM PARSER:

      No matches for:

        vector - matrix

      Available argument signatures for operator-:

        vector - vector
        row vector - row vector
        matrix - matrix
        vector - real
        row vector - real
        matrix - real
        real - vector
        real - row vector
        real - matrix

      expression is ill formed

      ERROR at line 4

        2:      vector[3] y;
        3:      matrix[3,4] z;
        4:      z <- y - z;
                          ^
        5:    }

      """
    'returns':
      'line': 4
      'col': 17
  }
  {
    'message':
      """
      Model name=err_decl_double_model
      Input file=test-models/bad/err-decl-double.stan
      Output file=test-models/bad/err-decl-double.cpp

      SYNTAX ERROR, MESSAGE(S) FROM PARSER:


      ERROR at line 2

        1:    data {
        2:      double y;
                ^
        3:    }

      PARSER EXPECTED: <one of the following:
        a variable declaration, beginning with type,
            (int, real, vector, row_vector, matrix, unit_vector,
             simplex, ordered, positive_ordered,
             corr_matrix, cov_matrix,
             cholesky_corr, cholesky_cov
        or '}' to close variable declarations>
      """
    'returns':
      'line': 2
      'col': 7
  }
]



describe "The stanc provider for Linter", ->

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('linter-stanc')

  it 'should be in the packages list', ->
    expect(atom.packages.isPackageLoaded('linter-stanc')).toBe(true)

  it 'should be an active package', ->
    expect(atom.packages.isPackageActive('linter-stanc')).toBe(true)

  describe "parse", ->
    for msg, i in messages
      do (msg, i) ->
        ret = linterStanc.parse(msg.message)
        if msg.returns?
          it "identifies error message #{i} as an error", ->
            expect(ret).not.toBeNull()
          it "identifies error message #{i} line number", ->
            expect(ret.line).toEqual(msg.returns.line)
          it "identifies error message #{i} column", ->
            expect(ret.col).toEqual(msg.returns.col)
        else
          it "identifies error message #{i} as not an error", ->
            expect(ret).toBeNull()
