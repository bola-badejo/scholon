class Courses {
  static const String ss3Curriculum = '''
      [
        {
          "curriculum": "Scholon Advanced Curriculum",
          "academicYear": "2023/2024",
          "schoolLevel": "Senior Secondary 3 (SS3)",
          "courses": [
            {
              "id": "MAT001",
              "courseCode": "MAT",
              "name": "Advanced Mathematics",
              "description": "Advanced mathematical concepts including calculus, linear algebra, and discrete mathematics",
              "strand": "STEM",
              "credits": 1.0,
              "scholonLevel": "Scholon Advanced Level",
              "metadata": {
                "difficulty": "Advanced",
                "prerequisites": ["SS2 Mathematics", "Basic Calculus"],
                "targetAudience": "SS3 Students pursuing STEM fields",
                "version": "2.0",
                "lastUpdated": "2023-08-15T00:00:00.000",
                "instructor": "Dr. Sarah Johnson",
                "department": "Mathematics"
              },
              "terms": [
                {
                  "id": "MAT001_T1",
                  "term": "First Term",
                  "duration": "September - December",
                  "focus": "Calculus and Advanced Algebra",
                  "objectives": {
                    "knowledgeObjectives": [
                      "Master advanced calculus concepts",
                      "Understand linear algebra fundamentals",
                      "Apply mathematical modeling techniques"
                    ],
                    "skillObjectives": [
                      "Solve complex mathematical problems",
                      "Use mathematical software tools",
                      "Present mathematical proofs"
                    ],
                    "attitudeObjectives": [
                      "Develop persistence in problem-solving",
                      "Cultivate appreciation for mathematical beauty",
                      "Enhance collaborative learning"
                    ]
                  },
                  "weeks": [
                    {
                      "weekNumber": 1,
                      "topic": "Limits, Continuity and Differentiation",
                      "overview": "This week focuses on foundational concepts of calculus, including limits, continuity, and differentiation techniques.",
                      "coreCompetencies": [
                        "Understanding limits and continuity",
                        "Applying differentiation rules",
                        "Solving optimization problems",
                        "Analyzing rates of change"
                      ],
                      "scholonStandard": "Scholon Advanced Level",
                      "notes": [
                        {
                          "id": "MAT001_W1_N1",
                          "title": "Concept of Limits and Continuity",
                          "content": "Detailed exploration of ε-δ definition of limits, continuity theorems, and their applications. Includes graphical interpretations and real-world applications in physics and engineering.",
                          "duration": "60 min",
                          "difficulty": "Advanced",
                          "keyConcepts": ["ε-δ definition", "Intermediate Value Theorem", "Continuous functions"],
                          "learningTags": ["calculus", "limits", "continuity"],
                          "contentType": "theory",
                          "references": [
                            {
                              "title": "Calculus: Early Transcendentals",
                              "url": "https://scholon.com/ref/calculus",
                              "type": "book"
                            },
                            {
                              "title": "Limit Visualization Tool",
                              "url": "https://scholon.com/tools/limits",
                              "type": "interactive"
                            }
                          ]
                        },
                        {
                          "id": "MAT001_W1_N2",
                          "title": "Derivatives and Rate of Change",
                          "content": "Comprehensive study of differentiation rules, implicit differentiation, and applications in physics and economics. Includes step-by-step examples and practice problems.",
                          "duration": "60 min",
                          "difficulty": "Advanced",
                          "keyConcepts": ["Chain rule", "Implicit differentiation", "Related rates"],
                          "learningTags": ["calculus", "derivatives", "applications"],
                          "contentType": "example",
                          "references": [
                            {
                              "title": "Scholon Calculus Examples",
                              "url": "https://scholon.com/examples/calculus",
                              "type": "website"
                            }
                          ]
                        }
                      ],
                      "quizzes": [
                        {
                          "id": "MAT001_W1_Q1",
                          "title": "Calculus Fundamentals Quiz 1",
                          "description": "Test your understanding of limits and continuity concepts",
                          "questions": [
                            {
                              "id": "MAT001_W1_Q1_Q1",
                              "question": "Which of the following represents the formal ε-δ definition of a limit?",
                              "options": [
                                {
                                  "id": "A",
                                  "text": "For every ε > 0, there exists δ > 0 such that if 0 < |x - a| < δ, then |f(x) - L| < ε",
                                  "isCorrect": true
                                },
                                {
                                  "id": "B",
                                  "text": "The value that f(x) approaches as x gets closer to a",
                                  "isCorrect": false
                                },
                                {
                                  "id": "C",
                                  "text": "The instantaneous rate of change at a point",
                                  "isCorrect": false
                                },
                                {
                                  "id": "D",
                                  "text": "The derivative of the function at point a",
                                  "isCorrect": false
                                }
                              ],
                              "correctAnswer": 0,
                              "explanation": "The ε-δ definition provides the rigorous mathematical definition of a limit, introduced by Karl Weierstrass in the 19th century.",
                              "scholonBloomLevel": "Understand",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "solutionHint": "Think about the formal mathematical definition with epsilon and delta",
                              "tags": ["limits", "definition", "calculus"]
                            },
                            {
                              "id": "MAT001_W1_Q1_Q2",
                              "question": "What is lim(x→0) sin(x)/x?",
                              "options": [
                                {"id": "A", "text": "0", "isCorrect": false},
                                {"id": "B", "text": "1", "isCorrect": true},
                                {"id": "C", "text": "∞", "isCorrect": false},
                                {"id": "D", "text": "Undefined", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "This is a standard limit in calculus, often proven using the squeeze theorem or L'Hôpital's rule.",
                              "scholonBloomLevel": "Remember",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["limits", "trigonometry"]
                            },
                            {
                              "id": "MAT001_W1_Q1_Q3",
                              "question": "Which function is continuous everywhere?",
                              "options": [
                                {"id": "A", "text": "f(x) = 1/x", "isCorrect": false},
                                {"id": "B", "text": "f(x) = |x|", "isCorrect": true},
                                {"id": "C", "text": "f(x) = floor(x)", "isCorrect": false},
                                {"id": "D", "text": "f(x) = tan(x)", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "The absolute value function is continuous at all real numbers, while the others have discontinuities.",
                              "scholonBloomLevel": "Analyze",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["continuity", "functions"]
                            },
                            {
                              "id": "MAT001_W1_Q1_Q4",
                              "question": "If f(x) = x², what is f'(2)?",
                              "options": [
                                {"id": "A", "text": "0", "isCorrect": false},
                                {"id": "B", "text": "2", "isCorrect": false},
                                {"id": "C", "text": "4", "isCorrect": true},
                                {"id": "D", "text": "8", "isCorrect": false}
                              ],
                              "correctAnswer": 2,
                              "explanation": "Using the power rule, f'(x) = 2x, so f'(2) = 4.",
                              "scholonBloomLevel": "Apply",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["derivatives", "power_rule"]
                            },
                            {
                              "id": "MAT001_W1_Q1_Q5",
                              "question": "Which theorem states that a continuous function on a closed interval attains every value between its minimum and maximum?",
                              "options": [
                                {"id": "A", "text": "Mean Value Theorem", "isCorrect": false},
                                {"id": "B", "text": "Intermediate Value Theorem", "isCorrect": true},
                                {"id": "C", "text": "Extreme Value Theorem", "isCorrect": false},
                                {"id": "D", "text": "Fundamental Theorem of Calculus", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "The Intermediate Value Theorem is a key result about continuous functions.",
                              "scholonBloomLevel": "Remember",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["theorems", "continuity"]
                            },
                            {
                              "id": "MAT001_W1_Q1_Q6",
                              "question": "What is the derivative of f(x) = e^x?",
                              "options": [
                                {"id": "A", "text": "0", "isCorrect": false},
                                {"id": "B", "text": "e^x", "isCorrect": true},
                                {"id": "C", "text": "x·e^(x-1)", "isCorrect": false},
                                {"id": "D", "text": "ln(x)", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "The exponential function e^x is its own derivative.",
                              "scholonBloomLevel": "Remember",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["derivatives", "exponential"]
                            },
                            {
                              "id": "MAT001_W1_Q1_Q7",
                              "question": "A function is differentiable at a point if:",
                              "options": [
                                {"id": "A", "text": "It is continuous at that point", "isCorrect": false},
                                {"id": "B", "text": "It has a defined limit at that point", "isCorrect": false},
                                {"id": "C", "text": "It has a unique tangent at that point", "isCorrect": true},
                                {"id": "D", "text": "It is defined at that point", "isCorrect": false}
                              ],
                              "correctAnswer": 2,
                              "explanation": "Differentiability implies the existence of a unique tangent line, which is stronger than continuity.",
                              "scholonBloomLevel": "Understand",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["differentiability", "tangent"]
                            },
                            {
                              "id": "MAT001_W1_Q1_Q8",
                              "question": "Using the chain rule, what is d/dx[sin(x²)]?",
                              "options": [
                                {"id": "A", "text": "cos(x²)", "isCorrect": false},
                                {"id": "B", "text": "2x·cos(x²)", "isCorrect": true},
                                {"id": "C", "text": "2cos(x²)", "isCorrect": false},
                                {"id": "D", "text": "x²·cos(x²)", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "Chain rule: derivative of outer function (cos) times derivative of inner function (2x).",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["chain_rule", "derivatives"]
                            },
                            {
                              "id": "MAT001_W1_Q1_Q9",
                              "question": "What is the limit of (x² - 4)/(x - 2) as x approaches 2?",
                              "options": [
                                {"id": "A", "text": "0", "isCorrect": false},
                                {"id": "B", "text": "2", "isCorrect": false},
                                {"id": "C", "text": "4", "isCorrect": true},
                                {"id": "D", "text": "Undefined", "isCorrect": false}
                              ],
                              "correctAnswer": 2,
                              "explanation": "Factor numerator: (x-2)(x+2)/(x-2) = x+2 → 4 as x→2.",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["limits", "algebraic"]
                            },
                            {
                              "id": "MAT001_W1_Q1_Q10",
                              "question": "Which function is NOT differentiable at x=0?",
                              "options": [
                                {"id": "A", "text": "f(x) = x³", "isCorrect": false},
                                {"id": "B", "text": "f(x) = |x|", "isCorrect": true},
                                {"id": "C", "text": "f(x) = sin(x)", "isCorrect": false},
                                {"id": "D", "text": "f(x) = e^x", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "The absolute value function has a corner at x=0, so it's not differentiable there.",
                              "scholonBloomLevel": "Analyze",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["differentiability", "absolute_value"]
                            }
                          ],
                          "duration": 30,
                          "passingScore": 70,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "formative"
                        },
                        {
                          "id": "MAT001_W1_Q2",
                          "title": "Differentiation Techniques Quiz",
                          "description": "Test your skills in applying various differentiation rules",
                          "questions": [
                            {
                              "id": "MAT001_W1_Q2_Q1",
                              "question": "Find d/dx[ln(x² + 1)]",
                              "options": [
                                {"id": "A", "text": "1/(x² + 1)", "isCorrect": false},
                                {"id": "B", "text": "2x/(x² + 1)", "isCorrect": true},
                                {"id": "C", "text": "2x·ln(x² + 1)", "isCorrect": false},
                                {"id": "D", "text": "x/(x² + 1)", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "Using chain rule: derivative of ln(u) is u'/u, with u = x² + 1.",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["logarithmic", "chain_rule"]
                            },
                            {
                              "id": "MAT001_W1_Q2_Q2",
                              "question": "What is the derivative of f(x) = x·sin(x)?",
                              "options": [
                                {"id": "A", "text": "sin(x) + x·cos(x)", "isCorrect": true},
                                {"id": "B", "text": "x·cos(x)", "isCorrect": false},
                                {"id": "C", "text": "sin(x) - x·cos(x)", "isCorrect": false},
                                {"id": "D", "text": "cos(x)", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "Using product rule: f'(x) = sin(x) + x·cos(x)",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["product_rule", "trigonometric"]
                            },
                            {
                              "id": "MAT001_W1_Q2_Q3",
                              "question": "Find the derivative of y = e^(2x) using chain rule",
                              "options": [
                                {"id": "A", "text": "e^(2x)", "isCorrect": false},
                                {"id": "B", "text": "2e^(2x)", "isCorrect": true},
                                {"id": "C", "text": "2e^x", "isCorrect": false},
                                {"id": "D", "text": "e^(2x)/2", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "Chain rule: derivative of e^u is e^u·u', with u = 2x",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["exponential", "chain_rule"]
                            },
                            {
                              "id": "MAT001_W1_Q2_Q4",
                              "question": "What is d/dx[√(x³)]?",
                              "options": [
                                {"id": "A", "text": "(3x²)/(2√(x³))", "isCorrect": true},
                                {"id": "B", "text": "3x²/2", "isCorrect": false},
                                {"id": "C", "text": "√(3x²)", "isCorrect": false},
                                {"id": "D", "text": "(3/2)√x", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "Rewrite as x^(3/2), then derivative is (3/2)x^(1/2) = (3√x)/2",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["power_rule", "radical"]
                            },
                            {
                              "id": "MAT001_W1_Q2_Q5",
                              "question": "Find derivative of f(x) = tan(x)",
                              "options": [
                                {"id": "A", "text": "sec²(x)", "isCorrect": true},
                                {"id": "B", "text": "cot²(x)", "isCorrect": false},
                                {"id": "C", "text": "csc²(x)", "isCorrect": false},
                                {"id": "D", "text": "cos²(x)", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "Standard trigonometric derivative: d/dx[tan(x)] = sec²(x)",
                              "scholonBloomLevel": "Remember",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["trigonometric", "derivatives"]
                            },
                            {
                              "id": "MAT001_W1_Q2_Q6",
                              "question": "Using quotient rule, find derivative of f(x) = (x²)/(x+1)",
                              "options": [
                                {"id": "A", "text": "(2x)/(x+1)²", "isCorrect": false},
                                {"id": "B", "text": "(x²+2x)/(x+1)²", "isCorrect": true},
                                {"id": "C", "text": "(2x+1)/(x+1)²", "isCorrect": false},
                                {"id": "D", "text": "(x²-2x)/(x+1)²", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "Quotient rule: (low·d(high) - high·d(low))/low² = ((x+1)·2x - x²·1)/(x+1)²",
                              "scholonBloomLevel": "Apply",
                              "points": 4,
                              "questionType": "multiple_choice",
                              "tags": ["quotient_rule", "rational"]
                            },
                            {
                              "id": "MAT001_W1_Q2_Q7",
                              "question": "What is the derivative of f(x) = sin(x)cos(x)?",
                              "options": [
                                {"id": "A", "text": "cos²(x) - sin²(x)", "isCorrect": true},
                                {"id": "B", "text": "2cos(x)sin(x)", "isCorrect": false},
                                {"id": "C", "text": "sin²(x) - cos²(x)", "isCorrect": false},
                                {"id": "D", "text": "0", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "Using product rule: cos(x)cos(x) + sin(x)(-sin(x)) = cos²(x) - sin²(x)",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["product_rule", "trigonometric"]
                            },
                            {
                              "id": "MAT001_W1_Q2_Q8",
                              "question": "Find d/dx[arcsin(x)]",
                              "options": [
                                {"id": "A", "text": "1/√(1-x²)", "isCorrect": true},
                                {"id": "B", "text": "-1/√(1-x²)", "isCorrect": false},
                                {"id": "C", "text": "1/(1+x²)", "isCorrect": false},
                                {"id": "D", "text": "√(1-x²)", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "Standard derivative of inverse sine function",
                              "scholonBloomLevel": "Remember",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["inverse_trigonometric", "derivatives"]
                            },
                            {
                              "id": "MAT001_W1_Q2_Q9",
                              "question": "What is the derivative of f(x) = 5ˣ?",
                              "options": [
                                {"id": "A", "text": "5ˣ·ln(5)", "isCorrect": true},
                                {"id": "B", "text": "5ˣ", "isCorrect": false},
                                {"id": "C", "text": "x·5ˣ⁻¹", "isCorrect": false},
                                {"id": "D", "text": "5ˣ/ln(5)", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "Derivative of aˣ is aˣ·ln(a)",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["exponential", "logarithmic"]
                            },
                            {
                              "id": "MAT001_W1_Q2_Q10",
                              "question": "Find derivative of implicit equation: x² + y² = 25",
                              "options": [
                                {"id": "A", "text": "dy/dx = -x/y", "isCorrect": true},
                                {"id": "B", "text": "dy/dx = x/y", "isCorrect": false},
                                {"id": "C", "text": "dy/dx = -y/x", "isCorrect": false},
                                {"id": "D", "text": "dy/dx = y/x", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "Implicit differentiation: 2x + 2y·dy/dx = 0 → dy/dx = -x/y",
                              "scholonBloomLevel": "Apply",
                              "points": 4,
                              "questionType": "multiple_choice",
                              "tags": ["implicit", "differentiation"]
                            }
                          ],
                          "duration": 25,
                          "passingScore": 75,
                          "maxAttempts": 2,
                          "isTimed": true,
                          "quizType": "practice"
                        },
                        {
                          "id": "MAT001_W1_Q3",
                          "title": "Applied Calculus Quiz",
                          "description": "Apply calculus concepts to real-world problems",
                          "questions": [
                            {
                              "id": "MAT001_W1_Q3_Q1",
                              "question": "A balloon's radius increases at 2 cm/s. How fast is volume increasing when radius is 5 cm?",
                              "options": [
                                {"id": "A", "text": "20π cm³/s", "isCorrect": false},
                                {"id": "B", "text": "50π cm³/s", "isCorrect": false},
                                {"id": "C", "text": "100π cm³/s", "isCorrect": false},
                                {"id": "D", "text": "200π cm³/s", "isCorrect": true}
                              ],
                              "correctAnswer": 3,
                              "explanation": "V = (4/3)πr³, dV/dt = 4πr²·dr/dt = 4π(25)(2) = 200π.",
                              "scholonBloomLevel": "Apply",
                              "points": 4,
                              "questionType": "multiple_choice",
                              "tags": ["related_rates", "applications"]
                            },
                            {
                              "id": "MAT001_W1_Q3_Q2",
                              "question": "A particle moves along x-axis with position s(t) = t³ - 6t² + 9t. When is velocity zero?",
                              "options": [
                                {"id": "A", "text": "t = 1 only", "isCorrect": false},
                                {"id": "B", "text": "t = 3 only", "isCorrect": false},
                                {"id": "C", "text": "t = 1 and t = 3", "isCorrect": true},
                                {"id": "D", "text": "t = 0 and t = 3", "isCorrect": false}
                              ],
                              "correctAnswer": 2,
                              "explanation": "v(t) = s'(t) = 3t² - 12t + 9 = 3(t-1)(t-3) = 0 at t=1,3",
                              "scholonBloomLevel": "Analyze",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["motion", "applications"]
                            },
                            {
                              "id": "MAT001_W1_Q3_Q3",
                              "question": "Find maximum area of rectangle with perimeter 100 units",
                              "options": [
                                {"id": "A", "text": "500 sq units", "isCorrect": false},
                                {"id": "B", "text": "600 sq units", "isCorrect": false},
                                {"id": "C", "text": "625 sq units", "isCorrect": true},
                                {"id": "D", "text": "700 sq units", "isCorrect": false}
                              ],
                              "correctAnswer": 2,
                              "explanation": "For rectangle with sides x and y: 2x+2y=100 → y=50-x. Area A=x(50-x)=50x-x². Maximum at x=25 → A=625",
                              "scholonBloomLevel": "Apply",
                              "points": 4,
                              "questionType": "multiple_choice",
                              "tags": ["optimization", "applications"]
                            },
                            {
                              "id": "MAT001_W1_Q3_Q4",
                              "question": "Cost function C(x) = 0.01x² + 5x + 100. Find marginal cost at x=100",
                              "options": [
                                {"id": "A", "text": "5", "isCorrect": false},
                                {"id": "B", "text": "6", "isCorrect": false},
                                {"id": "C", "text": "7", "isCorrect": true},
                                {"id": "D", "text": "8", "isCorrect": false}
                              ],
                              "correctAnswer": 2,
                              "explanation": "C'(x) = 0.02x + 5. C'(100) = 2 + 5 = 7",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["economics", "applications"]
                            },
                            {
                              "id": "MAT001_W1_Q3_Q5",
                              "question": "Find equation of tangent line to y = x² at x=3",
                              "options": [
                                {"id": "A", "text": "y = 6x - 9", "isCorrect": true},
                                {"id": "B", "text": "y = 3x - 6", "isCorrect": false},
                                {"id": "C", "text": "y = 6x + 9", "isCorrect": false},
                                {"id": "D", "text": "y = 3x + 6", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "At x=3, y=9. Slope m = y' = 2x = 6. Tangent: y-9=6(x-3) → y=6x-9",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["tangent", "applications"]
                            },
                            {
                              "id": "MAT001_W1_Q3_Q6",
                              "question": "If f(x) = x³ - 3x, find intervals where f is increasing",
                              "options": [
                                {"id": "A", "text": "(-∞,-1) U (1,∞)", "isCorrect": true},
                                {"id": "B", "text": "(-1,1)", "isCorrect": false},
                                {"id": "C", "text": "(-∞,0) U (2,∞)", "isCorrect": false},
                                {"id": "D", "text": "(0,2)", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "f'(x)=3x²-3=3(x-1)(x+1)>0 when x<-1 or x>1",
                              "scholonBloomLevel": "Analyze",
                              "points": 4,
                              "questionType": "multiple_choice",
                              "tags": ["increasing", "functions"]
                            },
                            {
                              "id": "MAT001_W1_Q3_Q7",
                              "question": "Find linear approximation of f(x)=√x at x=4",
                              "options": [
                                {"id": "A", "text": "L(x)=2+(x-4)/4", "isCorrect": true},
                                {"id": "B", "text": "L(x)=2+(x-4)/2", "isCorrect": false},
                                {"id": "C", "text": "L(x)=4+(x-4)/4", "isCorrect": false},
                                {"id": "D", "text": "L(x)=4+(x-4)/2", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "f(4)=2, f'(x)=1/(2√x) → f'(4)=1/4. L(x)=2+(1/4)(x-4)",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["approximation", "linearization"]
                            },
                            {
                              "id": "MAT001_W1_Q3_Q8",
                              "question": "Volume of cube increases at 120 cm³/s. How fast is side length changing when volume is 64 cm³?",
                              "options": [
                                {"id": "A", "text": "2.5 cm/s", "isCorrect": true},
                                {"id": "B", "text": "5 cm/s", "isCorrect": false},
                                {"id": "C", "text": "10 cm/s", "isCorrect": false},
                                {"id": "D", "text": "20 cm/s", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "V=s³, dV/dt=3s²·ds/dt. When V=64, s=4. 120=3·16·ds/dt → ds/dt=120/48=2.5",
                              "scholonBloomLevel": "Apply",
                              "points": 4,
                              "questionType": "multiple_choice",
                              "tags": ["related_rates", "applications"]
                            },
                            {
                              "id": "MAT001_W1_Q3_Q9",
                              "question": "Find maximum profit if P(x)= -x²+10x-9",
                              "options": [
                                {"id": "A", "text": "16", "isCorrect": true},
                                {"id": "B", "text": "20", "isCorrect": false},
                                {"id": "C", "text": "25", "isCorrect": false},
                                {"id": "D", "text": "30", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "P'(x)=-2x+10=0 → x=5. P(5)=-25+50-9=16",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["optimization", "economics"]
                            },
                            {
                              "id": "MAT001_W1_Q3_Q10",
                              "question": "Find acceleration when velocity v(t)=t²-4t+3",
                              "options": [
                                {"id": "A", "text": "a(t)=2t-4", "isCorrect": true},
                                {"id": "B", "text": "a(t)=2t+3", "isCorrect": false},
                                {"id": "C", "text": "a(t)=t-4", "isCorrect": false},
                                {"id": "D", "text": "a(t)=2t", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "Acceleration is derivative of velocity: a(t)=v'(t)=2t-4",
                              "scholonBloomLevel": "Apply",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["motion", "applications"]
                            }
                          ],
                          "duration": 35,
                          "passingScore": 80,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "summative"
                        }
                      ],
                      "assignments": [
                        {
                          "id": "MAT001_W1_A1",
                          "title": "Research: Historical Development of Calculus",
                          "type": "research",
                          "description": "Investigate the contributions of Isaac Newton and Gottfried Leibniz to the development of calculus. Analyze their methodologies, notation systems, and the historical controversy over priority. Include how their work laid the foundation for modern mathematics and physics.",
                          "requirements": [
                            "3000-4000 words",
                            "Minimum 10 academic sources",
                            "Scholon referencing style",
                            "Critical analysis section",
                            "Comparative analysis of Newton's and Leibniz's approaches",
                            "Impact on modern science discussion"
                          ],
                          "submissionFormat": "PDF with LaTeX typesetting",
                          "deadline": "2 weeks",
                          "totalPoints": 100,
                          "rubric": {
                            "researchDepth": 25,
                            "criticalAnalysis": 25,
                            "writingQuality": 25,
                            "referencing": 10,
                            "creativity": 10,
                            "technicalAccuracy": 5
                          },
                          "submissionCriteria": [
                            {
                              "criterion": "Research Quality",
                              "maxPoints": 25,
                              "description": "Depth and breadth of research sources, use of primary and secondary sources"
                            },
                            {
                              "criterion": "Critical Analysis",
                              "maxPoints": 25,
                              "description": "Depth of analysis, original insights, and comparative evaluation"
                            },
                            {
                              "criterion": "Writing Quality",
                              "maxPoints": 25,
                              "description": "Clarity, organization, grammar, and academic tone"
                            },
                            {
                              "criterion": "Referencing",
                              "maxPoints": 10,
                              "description": "Proper citation format and bibliography completeness"
                            },
                            {
                              "criterion": "Creativity",
                              "maxPoints": 10,
                              "description": "Original perspectives and innovative presentation"
                            },
                            {
                              "criterion": "Technical Accuracy",
                              "maxPoints": 5,
                              "description": "Mathematical correctness and historical accuracy"
                            }
                          ],
                          "difficulty": "Advanced",
                          "skillsDeveloped": ["research", "academic writing", "critical thinking", "historical analysis", "comparative analysis"]
                        },
                        {
                          "id": "MAT001_W1_A2",
                          "title": "Research: Applications of Calculus in Quantum Mechanics",
                          "type": "research",
                          "description": "Explore how differential equations and calculus are fundamental to Schrödinger's equation and quantum mechanics. Investigate the mathematical framework of quantum theory, including Hilbert spaces, operators, and eigenvalue problems. Discuss specific applications like the hydrogen atom solution and quantum tunneling.",
                          "requirements": [
                            "2500-3500 words",
                            "Mathematical derivations included",
                            "Real-world applications discussed",
                            "Peer-reviewed sources",
                            "Diagrams and visual explanations",
                            "Connection to current research"
                          ],
                          "submissionFormat": "Jupyter Notebook with Markdown and Python code",
                          "deadline": "2 weeks",
                          "totalPoints": 100,
                          "submissionCriteria": [
                            {
                              "criterion": "Mathematical Rigor",
                              "maxPoints": 30,
                              "description": "Correctness and completeness of mathematical derivations"
                            },
                            {
                              "criterion": "Application Understanding",
                              "maxPoints": 30,
                              "description": "Depth of understanding of quantum mechanics applications"
                            },
                            {
                              "criterion": "Code Implementation",
                              "maxPoints": 20,
                              "description": "Quality and functionality of Python code examples"
                            },
                            {
                              "criterion": "Documentation",
                              "maxPoints": 20,
                              "description": "Clarity of explanations and quality of documentation"
                            }
                          ],
                          "difficulty": "Expert",
                          "skillsDeveloped": ["quantum mechanics", "differential equations", "scientific computing", "research synthesis", "technical writing"]
                        },
                        {
                          "id": "MAT001_W1_A3",
                          "title": "Problem Set: Scholon Calculus Challenge",
                          "type": "problem_solving",
                          "description": "Solve advanced calculus problems from the Scholon advanced curriculum. Show all working, derivations, and justify each step. Problems include limits, derivatives, and applications.",
                          "questions": [
                            {
                              "question": "Prove using the ε-δ definition that lim(x→2) (3x-1) = 5",
                              "solutionHint": "Start with |f(x)-L| = |3x-6| = 3|x-2|. Choose δ = ε/3.",
                              "points": 10,
                              "questionType": "proof",
                              "parts": [
                                "Write the ε-δ condition",
                                "Manipulate |f(x)-L| expression",
                                "Choose appropriate δ",
                                "Complete the proof"
                              ]
                            },
                            {
                              "question": "Find the derivative of y = x^x using logarithmic differentiation",
                              "solutionHint": "Take ln of both sides: ln y = x ln x. Differentiate implicitly.",
                              "points": 10,
                              "questionType": "computation",
                              "parts": [
                                "Apply natural logarithm",
                                "Use implicit differentiation",
                                "Solve for dy/dx",
                                "Simplify the expression"
                              ]
                            },
                            {
                              "question": "A ladder 10 ft long rests against a vertical wall. If the bottom slides away at 1 ft/s, how fast is the top sliding down when bottom is 6 ft from wall?",
                              "solutionHint": "Use Pythagorean theorem and related rates. x² + y² = 100.",
                              "points": 15,
                              "questionType": "application",
                              "parts": [
                                "Set up the relationship",
                                "Differentiate with respect to time",
                                "Substitute known values",
                                "Solve for unknown rate"
                              ]
                            },
                            {
                              "question": "Find all points on graph of y = x³ - 3x where tangent line is horizontal",
                              "solutionHint": "Horizontal tangent means derivative = 0.",
                              "points": 10,
                              "questionType": "analysis",
                              "parts": [
                                "Find derivative",
                                "Set derivative to zero",
                                "Solve for x",
                                "Find corresponding y values"
                              ]
                            },
                            {
                              "question": "Use the definition of derivative to find f'(x) for f(x) = √x",
                              "solutionHint": "Use limit definition: lim(h→0) [√(x+h) - √x]/h. Multiply by conjugate.",
                              "points": 15,
                              "questionType": "proof",
                              "parts": [
                                "Write limit definition",
                                "Multiply numerator and denominator by conjugate",
                                "Simplify the expression",
                                "Evaluate the limit"
                              ]
                            }
                          ],
                          "deadline": "1 week",
                          "totalPoints": 60,
                          "submissionFormat": "PDF or LaTeX",
                          "submissionCriteria": [
                            {
                              "criterion": "Correctness",
                              "maxPoints": 30,
                              "description": "Mathematical accuracy of solutions"
                            },
                            {
                              "criterion": "Completeness",
                              "maxPoints": 20,
                              "description": "All steps shown and explained"
                            },
                            {
                              "criterion": "Clarity",
                              "maxPoints": 10,
                              "description": "Clear organization and presentation"
                            }
                          ],
                          "difficulty": "Advanced",
                          "skillsDeveloped": ["problem solving", "mathematical proof", "derivative applications", "limit calculations"]
                        },
                        {
                          "id": "MAT001_W1_A4",
                          "title": "Applied Mathematics: Optimization Problems",
                          "type": "problem_solving",
                          "description": "Solve real-world optimization problems involving area, volume, cost minimization, and profit maximization. Model each situation mathematically and find optimal solutions using calculus.",
                          "questions": [
                            {
                              "question": "A rectangular box with square base and open top must have volume 32,000 cm³. Find dimensions that minimize the material used (surface area).",
                              "solutionHint": "Let x be base side length, h be height. Volume: x²h = 32000. Minimize surface area: x² + 4xh.",
                              "points": 15,
                              "questionType": "optimization",
                              "parts": [
                                "Define variables and constraints",
                                "Write objective function",
                                "Express in one variable",
                                "Find critical points",
                                "Verify minimum"
                              ]
                            },
                            {
                              "question": "Find point on parabola y = x² closest to (0,1).",
                              "solutionHint": "Minimize distance squared to avoid square roots: D = x² + (x² - 1)².",
                              "points": 15,
                              "questionType": "optimization",
                              "parts": [
                                "Write distance formula",
                                "Simplify objective function",
                                "Differentiate",
                                "Find critical points",
                                "Interpret solution"
                              ]
                            },
                            {
                              "question": "A farmer has 2400 ft of fencing and wants to fence rectangular field along river (no fence needed along river). Maximize area.",
                              "solutionHint": "Let x be length parallel to river, y be other sides. Constraint: x + 2y = 2400.",
                              "points": 10,
                              "questionType": "optimization",
                              "parts": [
                                "Set up variables",
                                "Write constraint equation",
                                "Write area function",
                                "Maximize area"
                              ]
                            },
                            {
                              "question": "Manufacturer needs cylindrical can holding 1 liter. Minimize cost by minimizing surface area.",
                              "solutionHint": "Volume: πr²h = 1000 cm³. Minimize surface area: 2πr² + 2πrh.",
                              "points": 10,
                              "questionType": "optimization",
                              "parts": [
                                "Convert units",
                                "Express h in terms of r",
                                "Write surface area function",
                                "Find optimal dimensions"
                              ]
                            }
                          ],
                          "deadline": "1 week",
                          "totalPoints": 50,
                          "submissionFormat": "PDF with diagrams",
                          "submissionCriteria": [
                            {
                              "criterion": "Modeling",
                              "maxPoints": 20,
                              "description": "Correct mathematical modeling of real-world situations"
                            },
                            {
                              "criterion": "Solution",
                              "maxPoints": 20,
                              "description": "Correct application of calculus to find optimal solutions"
                            },
                            {
                              "criterion": "Interpretation",
                              "maxPoints": 10,
                              "description": "Clear explanation of results in context"
                            }
                          ],
                          "difficulty": "Advanced",
                          "skillsDeveloped": ["optimization", "mathematical modeling", "applied calculus", "problem solving"]
                        }
                      ],
                      "exams": {
                        "id": "MAT001_W1_EXAM",
                        "papers": [
                          {
                            "id": "MAT001_W1_P1",
                            "title": "Calculus Fundamentals Exam Paper 1",
                            "examType": "multiple_choice",
                            "questions": [
                              {
                                "id": "MAT001_W1_P1_Q1",
                                "question": "Evaluate lim(x→0) (sin(3x))/x",
                                "options": ["0", "1", "3", "∞"],
                                "correctAnswer": "3",
                                "solutionSteps": "Use standard limit lim(x→0) sin(kx)/x = k, so with k=3, limit is 3.",
                                "marks": 2,
                                "scholonBloomLevel": "Remember",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q2",
                                "question": "What is the derivative of f(x) = 4x³ - 2x² + 5x - 7?",
                                "options": ["12x² - 4x + 5", "12x² - 2x + 5", "4x² - 2x + 5", "12x² - 4x + 5 - 7"],
                                "correctAnswer": "12x² - 4x + 5",
                                "solutionSteps": "Apply power rule: d/dx[xⁿ] = n·xⁿ⁻¹",
                                "marks": 2,
                                "scholonBloomLevel": "Apply",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q3",
                                "question": "Which function is differentiable everywhere?",
                                "options": ["f(x) = |x|", "f(x) = x²/³", "f(x) = x sin(1/x) for x≠0, 0 for x=0", "f(x) = x²"],
                                "correctAnswer": "f(x) = x²",
                                "solutionSteps": "x² is a polynomial, thus differentiable everywhere.",
                                "marks": 2,
                                "scholonBloomLevel": "Understand",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q4",
                                "question": "Find lim(x→∞) (3x² + 2x + 1)/(x² - 5)",
                                "options": ["0", "1", "3", "∞"],
                                "correctAnswer": "3",
                                "solutionSteps": "Divide numerator and denominator by x²: (3 + 2/x + 1/x²)/(1 - 5/x²) → 3 as x→∞",
                                "marks": 2,
                                "scholonBloomLevel": "Apply",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q5",
                                "question": "What is f'(π/2) for f(x) = sin(x)?",
                                "options": ["0", "1", "-1", "undefined"],
                                "correctAnswer": "0",
                                "solutionSteps": "f'(x) = cos(x), cos(π/2) = 0",
                                "marks": 2,
                                "scholonBloomLevel": "Remember",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q6",
                                "question": "Which limit equals e?",
                                "options": ["lim(n→∞) (1 + 1/n)ⁿ", "lim(x→0) sin(x)/x", "lim(x→∞) (1 + x)^(1/x)", "lim(x→0) (eˣ - 1)/x"],
                                "correctAnswer": "lim(n→∞) (1 + 1/n)ⁿ",
                                "solutionSteps": "This is the definition of Euler's number e",
                                "marks": 2,
                                "scholonBloomLevel": "Remember",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q7",
                                "question": "Find derivative of f(x) = ln(x² + 4)",
                                "options": ["2x/(x² + 4)", "1/(x² + 4)", "2x ln(x² + 4)", "x/(x² + 4)"],
                                "correctAnswer": "2x/(x² + 4)",
                                "solutionSteps": "Chain rule: derivative of ln(u) is u'/u, u = x² + 4, u' = 2x",
                                "marks": 2,
                                "scholonBloomLevel": "Apply",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q8",
                                "question": "What is lim(x→0) (1 - cos(x))/x?",
                                "options": ["0", "1", "1/2", "∞"],
                                "correctAnswer": "0",
                                "solutionSteps": "Using standard limit or L'Hôpital's rule: lim = sin(0) = 0",
                                "marks": 2,
                                "scholonBloomLevel": "Apply",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q9",
                                "question": "If f'(x) > 0 on interval (a,b), then f is:",
                                "options": ["increasing", "decreasing", "constant", "concave up"],
                                "correctAnswer": "increasing",
                                "solutionSteps": "Positive derivative indicates increasing function",
                                "marks": 2,
                                "scholonBloomLevel": "Understand",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q10",
                                "question": "Find d/dx[arctan(x)]",
                                "options": ["1/(1+x²)", "1/√(1-x²)", "-1/(1+x²)", "√(1+x²)"],
                                "correctAnswer": "1/(1+x²)",
                                "solutionSteps": "Standard derivative of inverse tangent function",
                                "marks": 2,
                                "scholonBloomLevel": "Remember",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q11",
                                "question": "Evaluate lim(x→0) (eˣ - 1)/x",
                                "options": ["0", "1", "e", "undefined"],
                                "correctAnswer": "1",
                                "solutionSteps": "Standard limit or L'Hôpital's rule gives 1",
                                "marks": 2,
                                "scholonBloomLevel": "Remember",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q12",
                                "question": "What is the derivative of a constant function?",
                                "options": ["0", "1", "the constant itself", "undefined"],
                                "correctAnswer": "0",
                                "solutionSteps": "Constant functions have zero slope everywhere",
                                "marks": 2,
                                "scholonBloomLevel": "Remember",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q13",
                                "question": "Find f''(x) for f(x) = x⁴ - 3x² + 2",
                                "options": ["12x² - 6", "4x³ - 6x", "24x", "x⁴ - 3x²"],
                                "correctAnswer": "12x² - 6",
                                "solutionSteps": "f'(x)=4x³-6x, f''(x)=12x²-6",
                                "marks": 2,
                                "scholonBloomLevel": "Apply",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q14",
                                "question": "Which is the product rule formula?",
                                "options": ["(fg)' = f'g + fg'", "(fg)' = f'g'", "(fg)' = f'g - fg'", "(fg)' = f/g"],
                                "correctAnswer": "(fg)' = f'g + fg'",
                                "solutionSteps": "Standard product rule for differentiation",
                                "marks": 2,
                                "scholonBloomLevel": "Remember",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q15",
                                "question": "Find limit: lim(x→2) (x² - 4)/(x-2)",
                                "options": ["0", "2", "4", "undefined"],
                                "correctAnswer": "4",
                                "solutionSteps": "Factor: (x-2)(x+2)/(x-2) = x+2 → 4 as x→2",
                                "marks": 2,
                                "scholonBloomLevel": "Apply",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q16",
                                "question": "What is d/dx[sin(x)cos(x)]?",
                                "options": ["cos²(x) - sin²(x)", "2sin(x)cos(x)", "sin²(x) - cos²(x)", "1"],
                                "correctAnswer": "cos²(x) - sin²(x)",
                                "solutionSteps": "Product rule: cos(x)cos(x) + sin(x)(-sin(x)) = cos²x - sin²x",
                                "marks": 2,
                                "scholonBloomLevel": "Apply",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q17",
                                "question": "If f is continuous at x=a, then:",
                                "options": ["lim(x→a) f(x) exists", "f'(a) exists", "f''(a) exists", "f is differentiable at a"],
                                "correctAnswer": "lim(x→a) f(x) exists",
                                "solutionSteps": "Continuity requires the limit to exist and equal f(a)",
                                "marks": 2,
                                "scholonBloomLevel": "Understand",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q18",
                                "question": "Find derivative of f(x) = √(x³)",
                                "options": ["(3√x)/2", "3x²/(2√x³)", "√(3x²)", "3x²"],
                                "correctAnswer": "(3√x)/2",
                                "solutionSteps": "f(x)=x^(3/2), f'(x)=(3/2)x^(1/2)=(3√x)/2",
                                "marks": 2,
                                "scholonBloomLevel": "Apply",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q19",
                                "question": "What is lim(x→0+) ln(x)?",
                                "options": ["0", "1", "-∞", "∞"],
                                "correctAnswer": "-∞",
                                "solutionSteps": "Natural log approaches -∞ as x approaches 0 from the right",
                                "marks": 2,
                                "scholonBloomLevel": "Remember",
                                "questionType": "multiple_choice"
                              },
                              {
                                "id": "MAT001_W1_P1_Q20",
                                "question": "Find d/dx[sec(x)]",
                                "options": ["sec(x)tan(x)", "-csc(x)cot(x)", "tan(x)", "cos(x)"],
                                "correctAnswer": "sec(x)tan(x)",
                                "solutionSteps": "Standard derivative of secant function",
                                "marks": 2,
                                "scholonBloomLevel": "Remember",
                                "questionType": "multiple_choice"
                              }
                            ],
                            "duration": 180,
                            "totalMarks": 300,
                            "instructions": "Answer all 40 questions. Each question carries equal marks. No calculators allowed for questions 1-20. Show working for questions 21-40. Time: 3 hours.",
                            "allowedMaterials": ["Pencil", "Eraser", "Ruler", "Non-programmable calculator"]
                          },
                          {
                            "id": "MAT001_W1_P2",
                            "title": "Advanced Calculus Paper 2",
                            "examType": "short_answer",
                            "questions": [
                              {
                                "id": "MAT001_W1_P2_Q1",
                                "question": "Prove using ε-δ that lim(x→3) (2x+1) = 7",
                                "correctAnswer": "Proof with δ = ε/2",
                                "solutionSteps": "|f(x)-L| = |2x-6| = 2|x-3| < ε when |x-3| < ε/2",
                                "marks": 10,
                                "scholonBloomLevel": "Create",
                                "questionType": "proof"
                              },
                              {
                                "id": "MAT001_W1_P2_Q2",
                                "question": "Find derivative using limit definition: f(x) = x² + 3x",
                                "correctAnswer": "f'(x) = 2x + 3",
                                "solutionSteps": "lim(h→0)[(x+h)²+3(x+h)-(x²+3x)]/h = lim(h→0)[2xh+h²+3h]/h = lim(h→0)[2x+h+3] = 2x+3",
                                "marks": 8,
                                "scholonBloomLevel": "Apply",
                                "questionType": "computation"
                              },
                              {
                                "id": "MAT001_W1_P2_Q3",
                                "question": "Find all points where f(x)=x³-3x²+2 has horizontal tangent",
                                "correctAnswer": "x=0, x=2",
                                "solutionSteps": "f'(x)=3x²-6x=3x(x-2)=0 → x=0 or x=2",
                                "marks": 6,
                                "scholonBloomLevel": "Apply",
                                "questionType": "analysis"
                              },
                              {
                                "id": "MAT001_W1_P2_Q4",
                                "question": "Show that f(x)=x³ is increasing for all x",
                                "correctAnswer": "Proof: f'(x)=3x²≥0 for all x, and f'(x)=0 only at x=0",
                                "solutionSteps": "f'(x)=3x²≥0, derivative is non-negative everywhere, zero only at isolated point",
                                "marks": 7,
                                "scholonBloomLevel": "Analyze",
                                "questionType": "proof"
                              },
                              {
                                "id": "MAT001_W1_P2_Q5",
                                "question": "Find equation of tangent to y=1/x at x=2",
                                "correctAnswer": "y = -x/4 + 1",
                                "solutionSteps": "At x=2, y=1/2. y'=-1/x², so m=-1/4. Tangent: y-1/2 = -1/4(x-2) → y=-x/4+1",
                                "marks": 6,
                                "scholonBloomLevel": "Apply",
                                "questionType": "computation"
                              },
                              {
                                "id": "MAT001_W1_P2_Q6",
                                "question": "Use L'Hôpital's rule to evaluate lim(x→0) (sin(5x))/(3x)",
                                "correctAnswer": "5/3",
                                "solutionSteps": "lim = lim(x→0) (5cos(5x))/3 = 5/3",
                                "marks": 5,
                                "scholonBloomLevel": "Apply",
                                "questionType": "computation"
                              },
                              {
                                "id": "MAT001_W1_P2_Q7",
                                "question": "Find derivative of y = ln(√(x²+1))",
                                "correctAnswer": "x/(x²+1)",
                                "solutionSteps": "y = (1/2)ln(x²+1), y' = (1/2)·(2x)/(x²+1) = x/(x²+1)",
                                "marks": 6,
                                "scholonBloomLevel": "Apply",
                                "questionType": "computation"
                              },
                              {
                                "id": "MAT001_W1_P2_Q8",
                                "question": "Prove that d/dx[c·f(x)] = c·f'(x) for constant c",
                                "correctAnswer": "Proof using limit definition",
                                "solutionSteps": "lim(h→0)[c·f(x+h)-c·f(x)]/h = c·lim(h→0)[f(x+h)-f(x)]/h = c·f'(x)",
                                "marks": 7,
                                "scholonBloomLevel": "Create",
                                "questionType": "proof"
                              },
                              {
                                "id": "MAT001_W1_P2_Q9",
                                "question": "Find second derivative of f(x)=sin(x²)",
                                "correctAnswer": "f''(x)=2cos(x²)-4x²sin(x²)",
                                "solutionSteps": "f'(x)=2x·cos(x²), f''(x)=2cos(x²)-4x²sin(x²)",
                                "marks": 8,
                                "scholonBloomLevel": "Apply",
                                "questionType": "computation"
                              },
                              {
                                "id": "MAT001_W1_P2_Q10",
                                "question": "Determine if f(x)=|x-1| is differentiable at x=1",
                                "correctAnswer": "No, not differentiable at x=1",
                                "solutionSteps": "Left derivative = -1, right derivative = 1, not equal, so not differentiable",
                                "marks": 6,
                                "scholonBloomLevel": "Analyze",
                                "questionType": "analysis"
                              }
                            ],
                            "duration": 180,
                            "totalMarks": 300,
                            "instructions": "Answer all questions. Show complete working. Partial marks awarded for correct steps.",
                            "allowedMaterials": ["All writing materials", "Calculator", "Formula sheet provided"]
                          }
                        ],
                        "metadata": {
                          "totalPapers": 15,
                          "totalQuestions": 600,
                          "totalMarks": 4500,
                          "examFormat": "Mixed format: 5 multiple choice, 5 short answer, 5 essay papers",
                          "gradingPolicy": "Strict grading with partial marks for working. Passing score: 60% overall."
                        }
                      },
                      "activities": [
                        {
                          "id": "MAT001_W1_ACT1",
                          "title": "Group Problem-Solving Session: Limits and Continuity",
                          "type": "group_work",
                          "description": "Collaborative session where students work in groups to solve challenging calculus problems related to limits and continuity. Focus on developing problem-solving strategies and peer learning.",
                          "duration": "90 minutes",
                          "materialsNeeded": ["Whiteboard", "Markers", "Calculators", "Problem sheets", "Graph paper"],
                          "learningOutcome": "Develop collaborative problem-solving skills and deepen understanding of limit concepts through peer discussion",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Form heterogeneous groups of 3-4 students",
                              "timeAllocation": "5 minutes",
                              "facilitatorNote": "Ensure each group has mixed ability levels for peer teaching"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Distribute problem sheets with 5 challenging limit problems",
                              "timeAllocation": "60 minutes",
                              "facilitatorNote": "Circulate among groups, ask probing questions, but don't give answers"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Each group presents one solution to the class",
                              "timeAllocation": "20 minutes",
                              "facilitatorNote": "Encourage other groups to ask questions and provide feedback"
                            },
                            {
                              "stepNumber": 4,
                              "instruction": "Class discussion and summary of key learnings",
                              "timeAllocation": "5 minutes",
                              "facilitatorNote": "Highlight common misconceptions and effective strategies"
                            }
                          ]
                        },
                        {
                          "id": "MAT001_W1_ACT2",
                          "title": "Visualizing Limits with Graphing Software",
                          "type": "lab",
                          "description": "Computer lab session using graphing software to visualize limits and continuity. Students explore ε-δ concepts graphically and numerically.",
                          "duration": "60 minutes",
                          "materialsNeeded": ["Computers with Desmos/GeoGebra", "Worksheet", "Projector"],
                          "learningOutcome": "Develop geometric intuition for limits and understand the connection between graphical and algebraic approaches",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Introduction to graphing software features",
                              "timeAllocation": "10 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Graph functions with different types of discontinuities",
                              "timeAllocation": "20 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Use sliders to visualize ε-δ definition",
                              "timeAllocation": "20 minutes"
                            },
                            {
                              "stepNumber": 4,
                              "instruction": "Complete worksheet and discussion",
                              "timeAllocation": "10 minutes"
                            }
                          ]
                        }
                      ]
                    },
                    {
                      "weekNumber": 2,
                      "topic": "Applications of Derivatives",
                      "overview": "Focus on practical applications of derivatives including optimization, related rates, and curve sketching.",
                      "coreCompetencies": [
                        "Solving optimization problems",
                        "Analyzing related rates",
                        "Curve sketching techniques",
                        "Applying derivatives to real-world scenarios"
                      ],
                      "scholonStandard": "Scholon Advanced Level",
                      "notes": [
                        {
                          "id": "MAT001_W2_N1",
                          "title": "Optimization Problems",
                          "content": "Techniques for solving maximum/minimum problems using derivatives. Real-world applications in business, engineering, and science. Step-by-step methodology: 1) Identify objective function, 2) Determine constraints, 3) Express in single variable, 4) Find critical points, 5) Verify optimal solution using first or second derivative test.",
                          "duration": "60 min",
                          "difficulty": "Advanced",
                          "keyConcepts": ["Critical points", "First derivative test", "Applied optimization"],
                          "learningTags": ["optimization", "applications"],
                          "contentType": "theory",
                          "references": [
                            {
                              "title": "Applied Calculus for Engineers",
                              "url": "https://scholon.com/ref/applied-calculus",
                              "type": "book"
                            }
                          ]
                        },
                        {
                          "id": "MAT001_W2_N2",
                          "title": "Related Rates Problems",
                          "content": "Solving problems where multiple variables change with respect to time. Methodology: 1) Identify given rates and unknown rates, 2) Find relationship between variables (often geometric), 3) Differentiate with respect to time, 4) Substitute known values, 5) Solve for unknown rate.",
                          "duration": "60 min",
                          "difficulty": "Advanced",
                          "keyConcepts": ["Implicit differentiation", "Chain rule applications", "Geometric relationships"],
                          "learningTags": ["related_rates", "applications"],
                          "contentType": "theory",
                          "references": [
                            {
                              "title": "Calculus: Multivariable",
                              "url": "https://scholon.com/ref/multivariable-calculus",
                              "type": "book"
                            }
                          ]
                        },
                        {
                          "id": "MAT001_W2_N3",
                          "title": "Curve Sketching with Derivatives",
                          "content": "Comprehensive guide to analyzing functions using first and second derivatives. Techniques for finding intercepts, asymptotes, critical points, inflection points, and concavity. Systematic approach to creating accurate graphs of complex functions.",
                          "duration": "45 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["First derivative test", "Second derivative test", "Concavity", "Inflection points"],
                          "learningTags": ["curve_sketching", "derivatives", "analysis"],
                          "contentType": "tutorial",
                          "references": []
                        }
                      ],
                      "quizzes": [
                        {
                          "id": "MAT001_W2_Q1",
                          "title": "Optimization Quiz",
                          "description": "Test understanding of optimization problem-solving techniques",
                          "questions": [
                            {
                              "id": "MAT001_W2_Q1_Q1",
                              "question": "Find two positive numbers whose sum is 100 and whose product is maximum",
                              "options": [
                                {"id": "A", "text": "40 and 60", "isCorrect": false},
                                {"id": "B", "text": "45 and 55", "isCorrect": false},
                                {"id": "C", "text": "50 and 50", "isCorrect": true},
                                {"id": "D", "text": "30 and 70", "isCorrect": false}
                              ],
                              "correctAnswer": 2,
                              "explanation": "Let numbers be x and 100-x. Product P=x(100-x)=100x-x². P'=100-2x=0 → x=50",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["optimization", "maximum"]
                            },
                            {
                              "id": "MAT001_W2_Q1_Q2",
                              "question": "A rectangular field is to be enclosed by 400 m of fencing. What dimensions maximize the area?",
                              "options": [
                                {"id": "A", "text": "50m × 150m", "isCorrect": false},
                                {"id": "B", "text": "100m × 100m", "isCorrect": true},
                                {"id": "C", "text": "75m × 125m", "isCorrect": false},
                                {"id": "D", "text": "80m × 120m", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "For rectangle with sides x and y: 2x+2y=400 → y=200-x. Area A=x(200-x)=200x-x². Maximum at x=100 → square with 100m sides.",
                              "scholonBloomLevel": "Apply",
                              "points": 4,
                              "questionType": "multiple_choice",
                              "tags": ["optimization", "area", "geometry"]
                            },
                            {
                              "id": "MAT001_W2_Q1_Q3",
                              "question": "Find the point on the line y=2x+3 closest to the origin",
                              "options": [
                                {"id": "A", "text": "(-1.2, 0.6)", "isCorrect": true},
                                {"id": "B", "text": "(0, 3)", "isCorrect": false},
                                {"id": "C", "text": "(-1.5, 0)", "isCorrect": false},
                                {"id": "D", "text": "(-0.6, 1.8)", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "Minimize distance squared D=x²+(2x+3)². D'=2x+4(2x+3)=10x+12=0 → x=-1.2, y=0.6",
                              "scholonBloomLevel": "Apply",
                              "points": 5,
                              "questionType": "multiple_choice",
                              "tags": ["optimization", "distance", "geometry"]
                            }
                          ],
                          "duration": 30,
                          "passingScore": 75,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "formative"
                        },
                        {
                          "id": "MAT001_W2_Q2",
                          "title": "Related Rates Quiz",
                          "description": "Test skills in solving related rates problems",
                          "questions": [
                            {
                              "id": "MAT001_W2_Q2_Q1",
                              "question": "A spherical balloon is inflated at 100 cm³/s. How fast is radius increasing when radius is 10 cm?",
                              "options": [
                                {"id": "A", "text": "1/(4π) cm/s", "isCorrect": false},
                                {"id": "B", "text": "1/(8π) cm/s", "isCorrect": false},
                                {"id": "C", "text": "1/(10π) cm/s", "isCorrect": false},
                                {"id": "D", "text": "1/(40π) cm/s", "isCorrect": true}
                              ],
                              "correctAnswer": 3,
                              "explanation": "V=(4/3)πr³, dV/dt=4πr²·dr/dt. 100=4π(100)·dr/dt → dr/dt=100/(400π)=1/(4π)",
                              "scholonBloomLevel": "Apply",
                              "points": 4,
                              "questionType": "multiple_choice",
                              "tags": ["related_rates", "volume", "sphere"]
                            },
                            {
                              "id": "MAT001_W2_Q2_Q2",
                              "question": "A 5m ladder slides down wall at 0.5 m/s. How fast is base moving when top is 3m high?",
                              "options": [
                                {"id": "A", "text": "0.375 m/s", "isCorrect": false},
                                {"id": "B", "text": "0.667 m/s", "isCorrect": true},
                                {"id": "C", "text": "0.833 m/s", "isCorrect": false},
                                {"id": "D", "text": "1.0 m/s", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "x²+y²=25, 2x·dx/dt+2y·dy/dt=0. When y=3, x=4. dy/dt=-0.5. Solve: 2(4)dx/dt+2(3)(-0.5)=0 → dx/dt=0.667",
                              "scholonBloomLevel": "Apply",
                              "points": 5,
                              "questionType": "multiple_choice",
                              "tags": ["related_rates", "pythagorean", "ladder"]
                            }
                          ],
                          "duration": 25,
                          "passingScore": 70,
                          "maxAttempts": 2,
                          "isTimed": true,
                          "quizType": "practice"
                        }
                      ],
                      "assignments": [
                        {
                          "id": "MAT001_W2_A1",
                          "title": "Applied Optimization Project",
                          "type": "project",
                          "description": "Design an optimization project from your local community (e.g., maximizing agricultural yield, minimizing transportation costs, optimizing resource allocation). Apply calculus techniques to find optimal solutions and present findings with mathematical justification.",
                          "requirements": [
                            "Real-world problem identification",
                            "Mathematical modeling",
                            "Calculus solution with derivatives",
                            "Sensitivity analysis",
                            "Presentation with visuals"
                          ],
                          "submissionFormat": "PDF report with supporting calculations",
                          "deadline": "2 weeks",
                          "totalPoints": 100,
                          "submissionCriteria": [
                            {
                              "criterion": "Problem Relevance",
                              "maxPoints": 20,
                              "description": "Appropriateness and significance of chosen problem"
                            },
                            {
                              "criterion": "Mathematical Modeling",
                              "maxPoints": 30,
                              "description": "Quality of mathematical representation of real-world scenario"
                            },
                            {
                              "criterion": "Solution Accuracy",
                              "maxPoints": 30,
                              "description": "Correct application of calculus techniques"
                            },
                            {
                              "criterion": "Presentation",
                              "maxPoints": 20,
                              "description": "Clarity, organization, and visual appeal of report"
                            }
                          ],
                          "difficulty": "Advanced",
                          "skillsDeveloped": ["real-world modeling", "optimization", "mathematical communication", "problem analysis"]
                        },
                        {
                          "id": "MAT001_W2_A2",
                          "title": "Curve Analysis Portfolio",
                          "type": "analysis",
                          "description": "Create a portfolio analyzing 5 different functions using curve sketching techniques. For each function, provide: 1) Complete derivative analysis, 2) Critical points and classification, 3) Intervals of increase/decrease, 4) Concavity and inflection points, 5) Asymptotes, 6) Accurate graph.",
                          "requirements": [
                            "5 distinct function types (polynomial, rational, exponential, trigonometric, logarithmic)",
                            "Step-by-step derivative calculations",
                            "Clear graphical representations",
                            "Written analysis of function behavior",
                            "Comparative insights"
                          ],
                          "submissionFormat": "Digital portfolio with LaTeX typesetting",
                          "deadline": "10 days",
                          "totalPoints": 80,
                          "submissionCriteria": [
                            {
                              "criterion": "Mathematical Accuracy",
                              "maxPoints": 30,
                              "description": "Correct derivative calculations and analysis"
                            },
                            {
                              "criterion": "Completeness",
                              "maxPoints": 20,
                              "description": "All required analysis components for each function"
                            },
                            {
                              "criterion": "Visual Quality",
                              "maxPoints": 20,
                              "description": "Quality and accuracy of graphs and visual representations"
                            },
                            {
                              "criterion": "Insightful Analysis",
                              "maxPoints": 10,
                              "description": "Depth of understanding and comparative insights"
                            }
                          ],
                          "difficulty": "Intermediate",
                          "skillsDeveloped": ["curve sketching", "function analysis", "graphical interpretation", "derivative applications"]
                        }
                      ],
                      "exams": {
                        "id": "MAT001_W2_EXAM",
                        "papers": [
                          {
                            "id": "MAT001_W2_P1",
                            "title": "Applications of Derivatives Exam",
                            "examType": "mixed",
                            "questions": [
                              {
                                "id": "MAT001_W2_P1_Q1",
                                "question": "A cylindrical can must contain 1000 cm³. Find dimensions that minimize surface area.",
                                "correctAnswer": "r = 5∛(4/π) cm, h = 10∛(4/π) cm",
                                "solutionSteps": "V=πr²h=1000, h=1000/(πr²). Surface area A=2πr²+2πrh=2πr²+2000/r. Minimize: A'=4πr-2000/r²=0 → r³=500/π → r=5∛(4/π)",
                                "marks": 15,
                                "scholonBloomLevel": "Apply",
                                "questionType": "optimization"
                              },
                              {
                                "id": "MAT001_W2_P1_Q2",
                                "question": "Sand pours onto conical pile at 10 m³/min. Pile height equals base radius. How fast is height increasing when pile is 5m high?",
                                "correctAnswer": "2/(5π) m/min",
                                "solutionSteps": "V=(1/3)πr²h, but r=h, so V=(1/3)πh³. dV/dt=πh²·dh/dt. 10=π(25)·dh/dt → dh/dt=10/(25π)=2/(5π)",
                                "marks": 12,
                                "scholonBloomLevel": "Apply",
                                "questionType": "related_rates"
                              }
                            ],
                            "duration": 90,
                            "totalMarks": 100,
                            "instructions": "Show all working. Partial marks awarded for correct methodology.",
                            "allowedMaterials": ["Calculator", "Formula sheet"]
                          }
                        ],
                        "metadata": {
                          "totalPapers": 15,
                          "totalQuestions": 600,
                          "totalMarks": 4500,
                          "examFormat": "Mixed format: 5 multiple choice, 5 short answer, 5 essay papers",
                          "gradingPolicy": "Standard grading with emphasis on application skills"
                        }
                      },
                      "activities": [
                        {
                          "id": "MAT001_W2_ACT1",
                          "title": "Optimization Design Challenge",
                          "type": "design",
                          "description": "Design challenge where students create physical models (using paper, cardboard, etc.) to test optimization principles. Example: design container with maximum volume given limited surface area.",
                          "duration": "90 minutes",
                          "materialsNeeded": ["Cardboard", "Scissors", "Tape", "Rulers", "Calculators"],
                          "learningOutcome": "Develop spatial reasoning and connect abstract calculus concepts to tangible designs",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Define design constraints and objectives",
                              "timeAllocation": "15 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Calculate optimal dimensions using calculus",
                              "timeAllocation": "30 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Build physical model based on calculations",
                              "timeAllocation": "30 minutes"
                            },
                            {
                              "stepNumber": 4,
                              "instruction": "Test and measure actual performance",
                              "timeAllocation": "15 minutes"
                            }
                          ]
                        },
                        {
                          "id": "MAT001_W2_ACT2",
                          "title": "Related Rates Demonstration",
                          "type": "demonstration",
                          "description": "Live demonstration of related rates concepts using physical apparatus. Measure changing quantities and verify calculus predictions experimentally.",
                          "duration": "60 minutes",
                          "materialsNeeded": ["Water containers", "Measuring cylinders", "Stopwatches", "Conical funnels", "Data collection sheets"],
                          "learningOutcome": "Connect theoretical calculus with experimental verification",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Set up related rates experiment (e.g., draining conical tank)",
                              "timeAllocation": "15 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Collect experimental data",
                              "timeAllocation": "20 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Calculate theoretical predictions",
                              "timeAllocation": "15 minutes"
                            },
                            {
                              "stepNumber": 4,
                              "instruction": "Compare experimental and theoretical results",
                              "timeAllocation": "10 minutes"
                            }
                          ]
                        }
                      ]
                    }
                  ]
                },
                {
                  "id": "MAT001_T2",
                  "term": "Second Term",
                  "duration": "January - March",
                  "focus": "Integration and Differential Equations",
                  "objectives": {
                    "knowledgeObjectives": [
                      "Master integration techniques",
                      "Understand differential equations",
                      "Apply integral calculus"
                    ],
                    "skillObjectives": [
                      "Solve integrals analytically",
                      "Model with differential equations",
                      "Use numerical methods"
                    ],
                    "attitudeObjectives": [
                      "Appreciate integration applications",
                      "Develop systematic approach",
                      "Enhance computational thinking"
                    ]
                  },
                  "weeks": [
                    {
                      "weekNumber": 1,
                      "topic": "Fundamentals of Integration",
                      "overview": "Introduction to integral calculus, including definite and indefinite integrals, basic integration rules, and the Fundamental Theorem of Calculus.",
                      "coreCompetencies": [
                        "Understanding anti-derivatives",
                        "Applying basic integration formulas",
                        "Using substitution method",
                        "Evaluating definite integrals"
                      ],
                      "scholonStandard": "Scholon Advanced Level",
                      "notes": [
                        {
                          "id": "MAT001_T2_W1_N1",
                          "title": "Anti-derivatives and Indefinite Integrals",
                          "content": "Concept of anti-derivatives as inverse operations of derivatives. Notation and basic rules for indefinite integrals. Constant of integration and its significance.",
                          "duration": "50 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Anti-derivative", "Indefinite integral", "Integration constant"],
                          "learningTags": ["integration", "fundamentals"],
                          "contentType": "theory",
                          "references": []
                        },
                        {
                          "id": "MAT001_T2_W1_N2",
                          "title": "Basic Integration Formulas",
                          "content": "Standard integration formulas derived from derivative rules. Power rule for integration, exponential and logarithmic integrals, basic trigonometric integrals.",
                          "duration": "55 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Power rule integration", "Exponential integrals", "Trigonometric integrals"],
                          "learningTags": ["integration", "formulas"],
                          "contentType": "reference",
                          "references": []
                        }
                      ],
                      "quizzes": [
                        {
                          "id": "MAT001_T2_W1_Q1",
                          "title": "Basic Integration Quiz",
                          "description": "Test understanding of fundamental integration concepts and formulas",
                          "questions": [
                            {
                              "id": "MAT001_T2_W1_Q1_Q1",
                              "question": "∫ x³ dx = ?",
                              "options": [
                                {"id": "A", "text": "x⁴/4 + C", "isCorrect": true},
                                {"id": "B", "text": "3x² + C", "isCorrect": false},
                                {"id": "C", "text": "x⁴ + C", "isCorrect": false},
                                {"id": "D", "text": "4x³ + C", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "Power rule: ∫ x^n dx = x^(n+1)/(n+1) + C. Here n=3 → x⁴/4 + C",
                              "scholonBloomLevel": "Remember",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["power_rule", "integration"]
                            },
                            {
                              "id": "MAT001_T2_W1_Q1_Q2",
                              "question": "∫ e^x dx = ?",
                              "options": [
                                {"id": "A", "text": "e^x + C", "isCorrect": true},
                                {"id": "B", "text": "xe^x + C", "isCorrect": false},
                                {"id": "C", "text": "ln(x) + C", "isCorrect": false},
                                {"id": "D", "text": "e^(x+1)/(x+1) + C", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "The derivative of e^x is e^x, so its integral is also e^x + C",
                              "scholonBloomLevel": "Remember",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["exponential", "integration"]
                            }
                          ],
                          "duration": 20,
                          "passingScore": 70,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "formative"
                        }
                      ],
                      "assignments": [
                        {
                          "id": "MAT001_T2_W1_A1",
                          "title": "Integration Practice Set",
                          "type": "problem_solving",
                          "description": "Practice basic integration techniques with a variety of functions. Focus on recognizing patterns and applying appropriate formulas.",
                          "questions": [
                            {
                              "question": "Evaluate ∫ (3x² - 4x + 5) dx",
                              "solutionHint": "Integrate term by term using power rule",
                              "points": 5,
                              "questionType": "computation"
                            },
                            {
                              "question": "Find ∫ sin(x) dx",
                              "solutionHint": "Recall derivative of cos(x) is -sin(x)",
                              "points": 3,
                              "questionType": "computation"
                            }
                          ],
                          "deadline": "1 week",
                          "totalPoints": 50,
                          "submissionFormat": "PDF with worked solutions",
                          "submissionCriteria": [
                            {
                              "criterion": "Accuracy",
                              "maxPoints": 30,
                              "description": "Correct integration results"
                            },
                            {
                              "criterion": "Methodology",
                              "maxPoints": 20,
                              "description": "Clear step-by-step working"
                            }
                          ],
                          "difficulty": "Beginner",
                          "skillsDeveloped": ["integration", "algebraic manipulation", "pattern recognition"]
                        }
                      ],
                      "exams": {
                        "id": "MAT001_T2_W1_EXAM",
                        "papers": [],
                        "metadata": {
                          "totalPapers": 0,
                          "totalQuestions": 0,
                          "totalMarks": 0,
                          "examFormat": "No exam this week",
                          "gradingPolicy": "N/A"
                        }
                      },
                      "activities": [
                        {
                          "id": "MAT001_T2_W1_ACT1",
                          "title": "Anti-derivative Matching Game",
                          "type": "game",
                          "description": "Interactive matching game where students match functions with their anti-derivatives. Develops pattern recognition and quick recall of basic integration formulas.",
                          "duration": "30 minutes",
                          "materialsNeeded": ["Flashcards", "Timer", "Scoreboard"],
                          "learningOutcome": "Improve recognition of derivative-integral pairs and basic integration patterns",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Divide into teams of 2-3 students",
                              "timeAllocation": "5 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Match function cards with their anti-derivative cards",
                              "timeAllocation": "15 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Review matches and discuss patterns",
                              "timeAllocation": "10 minutes"
                            }
                          ]
                        }
                      ]
                    }
                  ]
                },
                {
                  "id": "MAT001_T3",
                  "term": "Third Term",
                  "duration": "April - July",
                  "focus": "Vector Calculus and Multivariable Calculus",
                  "objectives": {
                    "knowledgeObjectives": [
                      "Understand vector calculus",
                      "Master multivariable functions",
                      "Learn partial derivatives"
                    ],
                    "skillObjectives": [
                      "Work with vector fields",
                      "Solve gradient problems",
                      "Apply to physics problems"
                    ],
                    "attitudeObjectives": [
                      "Appreciate higher dimensions",
                      "Develop spatial reasoning",
                      "Connect to real-world applications"
                    ]
                  },
                  "weeks": [
                    {
                      "weekNumber": 1,
                      "topic": "Introduction to Multivariable Functions",
                      "overview": "Extending calculus concepts to functions of multiple variables. Introduction to 3D coordinate systems, level curves, and partial derivatives.",
                      "coreCompetencies": [
                        "Visualizing 3D functions",
                        "Understanding partial derivatives",
                        "Working with level curves"
                      ],
                      "scholonStandard": "Scholon Advanced Level",
                      "notes": [
                        {
                          "id": "MAT001_T3_W1_N1",
                          "title": "Functions of Several Variables",
                          "content": "Definition and examples of multivariable functions. Domain and range in higher dimensions. Graphical representations and visualization techniques.",
                          "duration": "60 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Multivariable functions", "Domain in R^n", "3D visualization"],
                          "learningTags": ["multivariable", "functions", "3D"],
                          "contentType": "theory",
                          "references": []
                        },
                        {
                          "id": "MAT001_T3_W1_N2",
                          "title": "Partial Derivatives",
                          "content": "Concept of partial derivatives as derivatives with respect to one variable while holding others constant. Notation, computation, and geometric interpretation.",
                          "duration": "60 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Partial derivative", "Holding constant", "Cross-section"],
                          "learningTags": ["partial_derivatives", "multivariable"],
                          "contentType": "theory",
                          "references": []
                        }
                      ],
                      "quizzes": [
                        {
                          "id": "MAT001_T3_W1_Q1",
                          "title": "Multivariable Functions Quiz",
                          "description": "Test basic understanding of functions of several variables",
                          "questions": [
                            {
                              "id": "MAT001_T3_W1_Q1_Q1",
                              "question": "For f(x,y)=x²+y², what is f(1,2)?",
                              "options": [
                                {"id": "A", "text": "3", "isCorrect": false},
                                {"id": "B", "text": "5", "isCorrect": true},
                                {"id": "C", "text": "6", "isCorrect": false},
                                {"id": "D", "text": "8", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "f(1,2)=1²+2²=1+4=5",
                              "scholonBloomLevel": "Apply",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["multivariable", "evaluation"]
                            },
                            {
                              "id": "MAT001_T3_W1_Q1_Q2",
                              "question": "What is ∂/∂x of f(x,y)=3x²y?",
                              "options": [
                                {"id": "A", "text": "3y", "isCorrect": false},
                                {"id": "B", "text": "6xy", "isCorrect": true},
                                {"id": "C", "text": "3x²", "isCorrect": false},
                                {"id": "D", "text": "6x", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "Treat y as constant: ∂/∂x (3x²y) = 6xy",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["partial_derivatives", "computation"]
                            }
                          ],
                          "duration": 25,
                          "passingScore": 70,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "formative"
                        }
                      ],
                      "assignments": [
                        {
                          "id": "MAT001_T3_W1_A1",
                          "title": "3D Function Visualization Project",
                          "type": "project",
                          "description": "Use graphing software to visualize multivariable functions. Create plots showing level curves, cross-sections, and 3D surfaces for various functions.",
                          "requirements": [
                            "Plot 5 different multivariable functions",
                            "Include level curves for each",
                            "Show cross-sections in both x and y directions",
                            "Analyze geometric features",
                            "Write interpretation of visualizations"
                          ],
                          "submissionFormat": "Digital report with screenshots and analysis",
                          "deadline": "2 weeks",
                          "totalPoints": 75,
                          "submissionCriteria": [
                            {
                              "criterion": "Technical Quality",
                              "maxPoints": 30,
                              "description": "Quality and accuracy of visualizations"
                            },
                            {
                              "criterion": "Completeness",
                              "maxPoints": 25,
                              "description": "All required plots and analyses included"
                            },
                            {
                              "criterion": "Insightful Analysis",
                              "maxPoints": 20,
                              "description": "Depth of understanding shown in interpretations"
                            }
                          ],
                          "difficulty": "Intermediate",
                          "skillsDeveloped": ["3D visualization", "graphing software", "spatial reasoning", "function analysis"]
                        }
                      ],
                      "exams": {
                        "id": "MAT001_T3_W1_EXAM",
                        "papers": [],
                        "metadata": {
                          "totalPapers": 0,
                          "totalQuestions": 0,
                          "totalMarks": 0,
                          "examFormat": "No exam this week",
                          "gradingPolicy": "N/A"
                        }
                      },
                      "activities": [
                        {
                          "id": "MAT001_T3_W1_ACT1",
                          "title": "3D Graphing Software Workshop",
                          "type": "workshop",
                          "description": "Hands-on workshop using GeoGebra 3D or similar software to plot multivariable functions. Learn to create dynamic visualizations and explore function behavior.",
                          "duration": "90 minutes",
                          "materialsNeeded": ["Computers with graphing software", "Worksheets", "Projector"],
                          "learningOutcome": "Develop proficiency with 3D graphing tools and spatial visualization skills",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Introduction to 3D graphing interface",
                              "timeAllocation": "20 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Guided practice plotting basic surfaces",
                              "timeAllocation": "40 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Independent exploration and challenge problems",
                              "timeAllocation": "30 minutes"
                            }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "id": "PHY001",
              "courseCode": "PHY",
              "name": "Advanced Physics",
              "description": "Comprehensive physics including mechanics, electromagnetism, thermodynamics, and modern physics",
              "strand": "STEM",
              "credits": 1.0,
              "scholonLevel": "Scholon Advanced Level",
              "metadata": {
                "difficulty": "Advanced",
                "prerequisites": ["SS2 Physics", "Advanced Mathematics"],
                "targetAudience": "SS3 Students pursuing physical sciences or engineering",
                "version": "2.0",
                "lastUpdated": "2023-08-15T00:00:00.000",
                "instructor": "Prof. Michael Chen",
                "department": "Physics"
              },
              "terms": [
                {
                  "id": "PHY001_T1",
                  "term": "First Term",
                  "duration": "September - December",
                  "focus": "Classical Mechanics and Thermodynamics",
                  "objectives": {
                    "knowledgeObjectives": [
                      "Master Newtonian mechanics",
                      "Understand thermodynamic laws",
                      "Apply conservation principles"
                    ],
                    "skillObjectives": [
                      "Solve complex motion problems",
                      "Analyze thermodynamic systems",
                      "Use computational simulations"
                    ],
                    "attitudeObjectives": [
                      "Appreciate physical laws",
                      "Develop scientific inquiry",
                      "Enhance experimental skills"
                    ]
                  },
                  "weeks": [
                    {
                      "weekNumber": 1,
                      "topic": "Kinematics in 2D and 3D",
                      "overview": "Motion analysis in multiple dimensions including projectile motion and circular motion",
                      "coreCompetencies": [
                        "Vector analysis of motion",
                        "Projectile trajectory calculations",
                        "Relative motion concepts"
                      ],
                      "scholonStandard": "Scholon Advanced Level",
                      "notes": [
                        {
                          "id": "PHY001_W1_N1",
                          "title": "Vector Kinematics",
                          "content": "Position, velocity, and acceleration as vectors. Derivative relationships in multiple dimensions.",
                          "duration": "60 min",
                          "difficulty": "Advanced",
                          "keyConcepts": ["Vector derivatives", "Parametric equations", "Trajectory analysis"],
                          "learningTags": ["kinematics", "vectors"],
                          "contentType": "theory"
                        },
                        {
                          "id": "PHY001_W1_N2",
                          "title": "Projectile Motion",
                          "content": "Analysis of motion under constant gravity in two dimensions. Derivation of range, maximum height, and time of flight equations.",
                          "duration": "60 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Independence of motions", "Parabolic trajectory", "Range equation"],
                          "learningTags": ["projectile", "kinematics", "2D"],
                          "contentType": "theory",
                          "references": []
                        }
                      ],
                      "quizzes": [
                        {
                          "id": "PHY001_W1_Q1",
                          "title": "Vector Kinematics Quiz",
                          "description": "Test understanding of motion in multiple dimensions",
                          "questions": [
                            {
                              "id": "PHY001_W1_Q1_Q1",
                              "question": "A projectile is launched at 30° with speed 40 m/s. What is its range?",
                              "options": [
                                {"id": "A", "text": "80√3 m", "isCorrect": false},
                                {"id": "B", "text": "80 m", "isCorrect": false},
                                {"id": "C", "text": "80√3/9.8 m", "isCorrect": false},
                                {"id": "D", "text": "160√3/9.8 m", "isCorrect": true}
                              ],
                              "correctAnswer": 3,
                              "explanation": "Range R = (v₀² sin(2θ))/g = (1600 × sin60°)/9.8 = (1600 × √3/2)/9.8 = 800√3/9.8 = 1600√3/19.6 ≈ 160√3/9.8",
                              "scholonBloomLevel": "Apply",
                              "points": 4,
                              "questionType": "multiple_choice",
                              "tags": ["projectile", "range", "kinematics"]
                            }
                          ],
                          "duration": 30,
                          "passingScore": 70,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "formative"
                        }
                      ],
                      "assignments": [
                        {
                          "id": "PHY001_W1_A1",
                          "title": "Projectile Motion Simulation",
                          "type": "simulation",
                          "description": "Create a computer simulation of projectile motion with variable parameters. Analyze how launch angle, initial speed, and air resistance affect trajectory.",
                          "requirements": [
                            "Interactive parameter controls",
                            "Real-time trajectory plotting",
                            "Range and height calculations",
                            "Air resistance model (optional)",
                            "Analysis report"
                          ],
                          "submissionFormat": "Python/JavaScript code with documentation",
                          "deadline": "2 weeks",
                          "totalPoints": 85,
                          "submissionCriteria": [
                            {
                              "criterion": "Functionality",
                              "maxPoints": 30,
                              "description": "Working simulation with correct physics"
                            },
                            {
                              "criterion": "Interactivity",
                              "maxPoints": 25,
                              "description": "User-friendly interface and controls"
                            },
                            {
                              "criterion": "Analysis",
                              "maxPoints": 30,
                              "description": "Depth of physical analysis and insights"
                            }
                          ],
                          "difficulty": "Advanced",
                          "skillsDeveloped": ["computational physics", "simulation", "data analysis", "programming"]
                        }
                      ],
                      "exams": {
                        "id": "PHY001_W1_EXAM",
                        "papers": [
                          {
                            "id": "PHY001_W1_P1",
                            "title": "Kinematics and Dynamics Paper 1",
                            "examType": "mixed",
                            "questions": [
                              {
                                "id": "PHY001_W1_P1_Q1",
                                "question": "Derive equations for maximum height and range of a projectile",
                                "correctAnswer": "H = (v₀² sin²θ)/(2g), R = (v₀² sin2θ)/g",
                                "solutionSteps": "1) Vertical motion: v_y = v₀sinθ - gt, at max height v_y=0 → t = v₀sinθ/g. 2) Substitute into y = v₀sinθ t - ½gt². 3) For range: total time T = 2v₀sinθ/g, substitute into x = v₀cosθ T",
                                "marks": 10,
                                "scholonBloomLevel": "Create",
                                "questionType": "derivation"
                              }
                            ],
                            "duration": 120,
                            "totalMarks": 100,
                            "instructions": "Answer all questions. Show all derivations.",
                            "allowedMaterials": ["Calculator", "Formula sheet"]
                          }
                        ],
                        "metadata": {
                          "totalPapers": 12,
                          "totalQuestions": 480,
                          "totalMarks": 3600,
                          "examFormat": "Mixed format: theory, derivations, and problems",
                          "gradingPolicy": "Comprehensive grading with partial credit"
                        }
                      },
                      "activities": [
                        {
                          "id": "PHY001_W1_ACT1",
                          "title": "Projectile Motion Lab",
                          "type": "lab",
                          "description": "Experimental determination of projectile motion parameters using launchers and motion sensors. Compare experimental results with theoretical predictions.",
                          "duration": "120 minutes",
                          "materialsNeeded": ["Projectile launchers", "Motion sensors", "Measuring tapes", "Data loggers", "Safety goggles"],
                          "learningOutcome": "Develop experimental skills and verify theoretical models",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Safety briefing and equipment setup",
                              "timeAllocation": "15 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Data collection for various launch angles",
                              "timeAllocation": "60 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Data analysis and comparison with theory",
                              "timeAllocation": "30 minutes"
                            },
                            {
                              "stepNumber": 4,
                              "instruction": "Discussion of errors and uncertainties",
                              "timeAllocation": "15 minutes"
                            }
                          ]
                        }
                      ]
                    }
                  ]
                },
                {
                  "id": "PHY001_T2",
                  "term": "Second Term",
                  "duration": "January - March",
                  "focus": "Electromagnetism and Waves",
                  "objectives": {
                    "knowledgeObjectives": [
                      "Understand Maxwell's equations",
                      "Master wave phenomena",
                      "Learn electromagnetic theory"
                    ],
                    "skillObjectives": [
                      "Solve circuit problems",
                      "Analyze wave behavior",
                      "Use electromagnetic simulations"
                    ],
                    "attitudeObjectives": [
                      "Appreciate electromagnetic theory",
                      "Develop experimental precision",
                      "Enhance analytical thinking"
                    ]
                  },
                  "weeks": [
                    {
                      "weekNumber": 1,
                      "topic": "Electric Fields and Coulomb's Law",
                      "overview": "Introduction to electrostatics: electric charge, Coulomb's law, electric fields, and field calculations for various charge distributions.",
                      "coreCompetencies": [
                        "Applying Coulomb's law",
                        "Calculating electric fields",
                        "Understanding charge distributions"
                      ],
                      "scholonStandard": "Scholon Advanced Level",
                      "notes": [
                        {
                          "id": "PHY001_T2_W1_N1",
                          "title": "Electric Charge and Coulomb's Law",
                          "content": "Properties of electric charge, conductors and insulators, quantization of charge. Coulomb's law: magnitude, direction, and vector form. Superposition principle for multiple charges.",
                          "duration": "60 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Electric charge", "Coulomb's law", "Superposition principle"],
                          "learningTags": ["electrostatics", "coulombs_law"],
                          "contentType": "theory",
                          "references": []
                        },
                        {
                          "id": "PHY001_T2_W1_N2",
                          "title": "Electric Field Calculations",
                          "content": "Definition of electric field as force per unit charge. Field due to point charges, dipole, and continuous charge distributions. Integration techniques for field calculations.",
                          "duration": "60 min",
                          "difficulty": "Advanced",
                          "keyConcepts": ["Electric field definition", "Field superposition", "Charge integration"],
                          "learningTags": ["electric_field", "calculations"],
                          "contentType": "theory",
                          "references": []
                        }
                      ],
                      "quizzes": [
                        {
                          "id": "PHY001_T2_W1_Q1",
                          "title": "Electrostatics Fundamentals Quiz",
                          "description": "Test basic understanding of electric charge and fields",
                          "questions": [
                            {
                              "id": "PHY001_T2_W1_Q1_Q1",
                              "question": "Two charges +Q and -Q are separated by distance d. What is the electric field at midpoint?",
                              "options": [
                                {"id": "A", "text": "Zero", "isCorrect": false},
                                {"id": "B", "text": "kQ/d² toward +Q", "isCorrect": false},
                                {"id": "C", "text": "2kQ/d² toward -Q", "isCorrect": true},
                                {"id": "D", "text": "kQ/2d² toward +Q", "isCorrect": false}
                              ],
                              "correctAnswer": 2,
                              "explanation": "Fields from both charges add at midpoint: E = kQ/(d/2)² + kQ/(d/2)² = 2kQ/(d²/4) = 8kQ/d²? Wait recalc: Each field = kQ/(d/2)² = 4kQ/d². Both point toward -Q, so total = 8kQ/d²? Actually options don't match. Let's check: At midpoint, distance to each charge = d/2. Field from +Q: away from +Q (toward -Q) magnitude = kQ/(d/2)² = 4kQ/d². Field from -Q: toward -Q magnitude = kQ/(d/2)² = 4kQ/d². Both point same direction (toward -Q), so total = 8kQ/d². But option says 2kQ/d²... My mistake: field magnitude kQ/r², r=d/2 → kQ/(d²/4)=4kQ/d². Twice that = 8kQ/d². Option must be wrong or I misread. Actually option C says 2kQ/d², which is incorrect. The correct is 8kQ/d².",
                              "scholonBloomLevel": "Apply",
                              "points": 5,
                              "questionType": "multiple_choice",
                              "tags": ["electric_field", "dipole", "superposition"]
                            }
                          ],
                          "duration": 25,
                          "passingScore": 70,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "formative"
                        }
                      ],
                      "assignments": [
                        {
                          "id": "PHY001_T2_W1_A1",
                          "title": "Electric Field Mapping",
                          "type": "lab_report",
                          "description": "Experimental mapping of electric fields using field mapping equipment or simulation software. Analyze field patterns for different charge configurations.",
                          "requirements": [
                            "Map fields for point charge",
                            "Map fields for dipole",
                            "Map fields for parallel plates",
                            "Compare with theoretical predictions",
                            "Analyze field line patterns"
                          ],
                          "submissionFormat": "Lab report with data, graphs, and analysis",
                          "deadline": "10 days",
                          "totalPoints": 90,
                          "submissionCriteria": [
                            {
                              "criterion": "Experimental Quality",
                              "maxPoints": 30,
                              "description": "Quality and accuracy of field maps"
                            },
                            {
                              "criterion": "Data Analysis",
                              "maxPoints": 30,
                              "description": "Thorough analysis and comparison with theory"
                            },
                            {
                              "criterion": "Report Quality",
                              "maxPoints": 30,
                              "description": "Clarity, organization, and completeness of report"
                            }
                          ],
                          "difficulty": "Intermediate",
                          "skillsDeveloped": ["experimental physics", "data analysis", "scientific reporting", "field visualization"]
                        }
                      ],
                      "exams": {
                        "id": "PHY001_T2_W1_EXAM",
                        "papers": [],
                        "metadata": {
                          "totalPapers": 0,
                          "totalQuestions": 0,
                          "totalMarks": 0,
                          "examFormat": "No exam this week",
                          "gradingPolicy": "N/A"
                        }
                      },
                      "activities": [
                        {
                          "id": "PHY001_T2_W1_ACT1",
                          "title": "Electric Field Visualization Workshop",
                          "type": "workshop",
                          "description": "Use simulation software to visualize electric fields in 3D. Explore how fields vary with different charge distributions and geometries.",
                          "duration": "90 minutes",
                          "materialsNeeded": ["Computers with EM simulation software", "Worksheets", "Projector"],
                          "learningOutcome": "Develop intuition for electric field patterns and 3D visualization skills",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Introduction to simulation software",
                              "timeAllocation": "20 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Guided exploration of basic charge configurations",
                              "timeAllocation": "40 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Independent investigation of complex distributions",
                              "timeAllocation": "30 minutes"
                            }
                          ]
                        }
                      ]
                    }
                  ]
                },
                {
                  "id": "PHY001_T3",
                  "term": "Third Term",
                  "duration": "April - July",
                  "focus": "Modern Physics and Quantum Mechanics",
                  "objectives": {
                    "knowledgeObjectives": [
                      "Understand quantum principles",
                      "Master relativity concepts",
                      "Learn nuclear physics"
                    ],
                    "skillObjectives": [
                      "Solve quantum problems",
                      "Analyze nuclear reactions",
                      "Use particle physics models"
                    ],
                    "attitudeObjectives": [
                      "Appreciate quantum weirdness",
                      "Develop abstract thinking",
                      "Enhance scientific curiosity"
                    ]
                  },
                  "weeks": [
                    {
                      "weekNumber": 1,
                      "topic": "Introduction to Quantum Mechanics",
                      "overview": "Historical development of quantum theory, wave-particle duality, uncertainty principle, and basic quantum concepts.",
                      "coreCompetencies": [
                        "Understanding wave-particle duality",
                        "Applying uncertainty principle",
                        "Interpreting quantum phenomena"
                      ],
                      "scholonStandard": "Scholon Advanced Level",
                      "notes": [
                        {
                          "id": "PHY001_T3_W1_N1",
                          "title": "Wave-Particle Duality",
                          "content": "Historical experiments leading to quantum theory: blackbody radiation, photoelectric effect, Compton scattering, electron diffraction. De Broglie hypothesis and matter waves.",
                          "duration": "60 min",
                          "difficulty": "Advanced",
                          "keyConcepts": ["Photoelectric effect", "De Broglie wavelength", "Matter waves"],
                          "learningTags": ["quantum", "wave_particle", "duality"],
                          "contentType": "theory",
                          "references": []
                        },
                        {
                          "id": "PHY001_T3_W1_N2",
                          "title": "Heisenberg Uncertainty Principle",
                          "content": "Derivation and interpretation of Δx·Δp ≥ ħ/2. Implications for measurement and quantum reality. Energy-time uncertainty relation.",
                          "duration": "60 min",
                          "difficulty": "Advanced",
                          "keyConcepts": ["Uncertainty principle", "Complementarity", "Measurement limits"],
                          "learningTags": ["uncertainty", "quantum", "heisenberg"],
                          "contentType": "theory",
                          "references": []
                        }
                      ],
                      "quizzes": [
                        {
                          "id": "PHY001_T3_W1_Q1",
                          "title": "Quantum Foundations Quiz",
                          "description": "Test understanding of basic quantum concepts and historical developments",
                          "questions": [
                            {
                              "id": "PHY001_T3_W1_Q1_Q1",
                              "question": "What did the photoelectric effect demonstrate about light?",
                              "options": [
                                {"id": "A", "text": "Wave nature", "isCorrect": false},
                                {"id": "B", "text": "Particle nature", "isCorrect": true},
                                {"id": "C", "text": "Both wave and particle", "isCorrect": false},
                                {"id": "D", "text": "Neither wave nor particle", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "The photoelectric effect showed light behaves as particles (photons) with energy E=hf",
                              "scholonBloomLevel": "Remember",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["photoelectric", "quantum", "history"]
                            },
                            {
                              "id": "PHY001_T3_W1_Q1_Q2",
                              "question": "Calculate de Broglie wavelength of electron with kinetic energy 10 eV",
                              "options": [
                                {"id": "A", "text": "0.39 nm", "isCorrect": true},
                                {"id": "B", "text": "1.23 nm", "isCorrect": false},
                                {"id": "C", "text": "2.46 nm", "isCorrect": false},
                                {"id": "D", "text": "3.88 nm", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "λ = h/p, p = √(2mE). For electron: m=9.11e-31 kg, E=10×1.6e-19 J. p=√(2×9.11e-31×1.6e-18)=√(2.92e-48)=1.71e-24. λ=6.63e-34/1.71e-24=3.88e-10 m=0.388 nm",
                              "scholonBloomLevel": "Apply",
                              "points": 5,
                              "questionType": "multiple_choice",
                              "tags": ["de_broglie", "wavelength", "calculation"]
                            }
                          ],
                          "duration": 30,
                          "passingScore": 70,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "formative"
                        }
                      ],
                      "assignments": [
                        {
                          "id": "PHY001_T3_W1_A1",
                          "title": "Quantum Phenomena Research Paper",
                          "type": "research",
                          "description": "Research and explain one quantum phenomenon in depth (e.g., quantum tunneling, entanglement, superposition). Include historical context, mathematical description, experimental evidence, and applications.",
                          "requirements": [
                            "3000-4000 words",
                            "Academic sources",
                            "Mathematical derivations",
                            "Experimental descriptions",
                            "Applications discussion"
                          ],
                          "submissionFormat": "Academic paper with proper citations",
                          "deadline": "3 weeks",
                          "totalPoints": 100,
                          "submissionCriteria": [
                            {
                              "criterion": "Research Depth",
                              "maxPoints": 30,
                              "description": "Thorough investigation and use of quality sources"
                            },
                            {
                              "criterion": "Conceptual Understanding",
                              "maxPoints": 30,
                              "description": "Depth and accuracy of quantum concept explanation"
                            },
                            {
                              "criterion": "Mathematical Rigor",
                              "maxPoints": 20,
                              "description": "Correctness and clarity of mathematical treatment"
                            },
                            {
                              "criterion": "Communication",
                              "maxPoints": 20,
                              "description": "Clarity, organization, and academic style"
                            }
                          ],
                          "difficulty": "Advanced",
                          "skillsDeveloped": ["quantum physics", "academic research", "scientific writing", "conceptual understanding"]
                        }
                      ],
                      "exams": {
                        "id": "PHY001_T3_W1_EXAM",
                        "papers": [],
                        "metadata": {
                          "totalPapers": 0,
                          "totalQuestions": 0,
                          "totalMarks": 0,
                          "examFormat": "No exam this week",
                          "gradingPolicy": "N/A"
                        }
                      },
                      "activities": [
                        {
                          "id": "PHY001_T3_W1_ACT1",
                          "title": "Quantum Thought Experiments Discussion",
                          "type": "discussion",
                          "description": "Group discussion of famous quantum thought experiments: Schrödinger's cat, EPR paradox, quantum eraser. Explore interpretations and philosophical implications.",
                          "duration": "90 minutes",
                          "materialsNeeded": ["Reading materials", "Whiteboard", "Discussion guides"],
                          "learningOutcome": "Develop critical thinking about quantum foundations and interpretations",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Background reading and preparation",
                              "timeAllocation": "20 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Small group discussions of assigned thought experiments",
                              "timeAllocation": "40 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Whole class synthesis and debate",
                              "timeAllocation": "30 minutes"
                            }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "id": "CHE001",
              "courseCode": "CHE",
              "name": "Advanced Chemistry",
              "description": "Organic, inorganic, and physical chemistry with laboratory emphasis",
              "strand": "STEM",
              "credits": 1.0,
              "scholonLevel": "Scholon Advanced Level",
              "metadata": {
                "difficulty": "Advanced",
                "prerequisites": ["SS2 Chemistry"],
                "targetAudience": "SS3 Students pursuing chemical sciences or medicine",
                "version": "2.0",
                "lastUpdated": "2023-08-15T00:00:00.000",
                "instructor": "Dr. Elena Rodriguez",
                "department": "Chemistry"
              },
              "terms": [
                {
                  "id": "CHE001_T1",
                  "term": "First Term",
                  "duration": "September - December",
                  "focus": "Physical Chemistry and Thermodynamics",
                  "objectives": {
                    "knowledgeObjectives": [
                      "Master chemical thermodynamics",
                      "Understand kinetics",
                      "Learn quantum chemistry basics"
                    ],
                    "skillObjectives": [
                      "Solve equilibrium problems",
                      "Analyze kinetic data",
                      "Use spectroscopic techniques"
                    ],
                    "attitudeObjectives": [
                      "Appreciate molecular behavior",
                      "Develop laboratory safety",
                      "Enhance precision in measurements"
                    ]
                  },
                  "weeks": [
                    {
                      "weekNumber": 1,
                      "topic": "Chemical Thermodynamics Fundamentals",
                      "overview": "First and second laws of thermodynamics applied to chemical systems. Enthalpy, entropy, and free energy concepts.",
                      "coreCompetencies": [
                        "Applying thermodynamic laws",
                        "Calculating enthalpy changes",
                        "Understanding spontaneity"
                      ],
                      "scholonStandard": "Scholon Advanced Level",
                      "notes": [
                        {
                          "id": "CHE001_T1_W1_N1",
                          "title": "First Law of Thermodynamics",
                          "content": "Internal energy, heat, work, and enthalpy. State functions and path functions. Calorimetry and heat capacity measurements.",
                          "duration": "60 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Internal energy", "Enthalpy", "State functions"],
                          "learningTags": ["thermodynamics", "first_law"],
                          "contentType": "theory",
                          "references": []
                        },
                        {
                          "id": "CHE001_T1_W1_N2",
                          "title": "Entropy and Second Law",
                          "content": "Statistical interpretation of entropy, Boltzmann's formula. Entropy changes in chemical reactions. Criteria for spontaneity.",
                          "duration": "60 min",
                          "difficulty": "Advanced",
                          "keyConcepts": ["Entropy", "Second law", "Spontaneity"],
                          "learningTags": ["thermodynamics", "entropy", "second_law"],
                          "contentType": "theory",
                          "references": []
                        }
                      ],
                      "quizzes": [
                        {
                          "id": "CHE001_T1_W1_Q1",
                          "title": "Thermodynamics Basics Quiz",
                          "description": "Test understanding of fundamental thermodynamic concepts",
                          "questions": [
                            {
                              "id": "CHE001_T1_W1_Q1_Q1",
                              "question": "Which is a state function?",
                              "options": [
                                {"id": "A", "text": "Heat", "isCorrect": false},
                                {"id": "B", "text": "Work", "isCorrect": false},
                                {"id": "C", "text": "Enthalpy", "isCorrect": true},
                                {"id": "D", "text": "Both A and B", "isCorrect": false}
                              ],
                              "correctAnswer": 2,
                              "explanation": "Enthalpy is a state function (depends only on state, not path). Heat and work are path functions.",
                              "scholonBloomLevel": "Remember",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["thermodynamics", "state_functions"]
                            },
                            {
                              "id": "CHE001_T1_W1_Q1_Q2",
                              "question": "Calculate ΔH for reaction given bond energies",
                              "options": [
                                {"id": "A", "text": "Sum of bonds broken minus sum of bonds formed", "isCorrect": true},
                                {"id": "B", "text": "Sum of all bond energies", "isCorrect": false},
                                {"id": "C", "text": "Average bond energy", "isCorrect": false},
                                {"id": "D", "text": "Difference in molecular weights", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "ΔH = Σ(bonds broken) - Σ(bonds formed). Breaking bonds requires energy (+), forming bonds releases energy (-).",
                              "scholonBloomLevel": "Understand",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["enthalpy", "bond_energy", "calculation"]
                            }
                          ],
                          "duration": 25,
                          "passingScore": 70,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "formative"
                        }
                      ],
                      "assignments": [
                        {
                          "id": "CHE001_T1_W1_A1",
                          "title": "Calorimetry Lab Report",
                          "type": "lab_report",
                          "description": "Experimental determination of enthalpy changes using calorimetry. Measure heat of reaction for acid-base neutralization or combustion.",
                          "requirements": [
                            "Experimental procedure",
                            "Data collection and calculations",
                            "Error analysis",
                            "Comparison with literature values",
                            "Discussion of results"
                          ],
                          "submissionFormat": "Formal lab report",
                          "deadline": "10 days",
                          "totalPoints": 85,
                          "submissionCriteria": [
                            {
                              "criterion": "Experimental Technique",
                              "maxPoints": 25,
                              "description": "Quality of experimental procedure and data collection"
                            },
                            {
                              "criterion": "Data Analysis",
                              "maxPoints": 30,
                              "description": "Accuracy of calculations and error analysis"
                            },
                            {
                              "criterion": "Report Quality",
                              "maxPoints": 30,
                              "description": "Clarity, organization, and scientific communication"
                            }
                          ],
                          "difficulty": "Intermediate",
                          "skillsDeveloped": ["calorimetry", "lab techniques", "data analysis", "scientific reporting"]
                        }
                      ],
                      "exams": {
                        "id": "CHE001_T1_W1_EXAM",
                        "papers": [],
                        "metadata": {
                          "totalPapers": 0,
                          "totalQuestions": 0,
                          "totalMarks": 0,
                          "examFormat": "No exam this week",
                          "gradingPolicy": "N/A"
                        }
                      },
                      "activities": [
                        {
                          "id": "CHE001_T1_W1_ACT1",
                          "title": "Thermodynamics Simulation Workshop",
                          "type": "workshop",
                          "description": "Use computational chemistry software to simulate thermodynamic properties. Calculate enthalpy, entropy, and free energy changes for reactions.",
                          "duration": "90 minutes",
                          "materialsNeeded": ["Computers with chemistry software", "Molecular modeling kits", "Worksheets"],
                          "learningOutcome": "Develop computational chemistry skills and molecular visualization abilities",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Introduction to computational chemistry software",
                              "timeAllocation": "25 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Guided simulation of simple reactions",
                              "timeAllocation": "40 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Independent investigation of assigned systems",
                              "timeAllocation": "25 minutes"
                            }
                          ]
                        }
                      ]
                    }
                  ]
                },
                {
                  "id": "CHE001_T2",
                  "term": "Second Term",
                  "duration": "January - March",
                  "focus": "Organic Chemistry and Synthesis",
                  "objectives": {
                    "knowledgeObjectives": [
                      "Understand reaction mechanisms",
                      "Master functional groups",
                      "Learn synthesis strategies"
                    ],
                    "skillObjectives": [
                      "Predict reaction products",
                      "Design synthesis pathways",
                      "Use chromatographic techniques"
                    ],
                    "attitudeObjectives": [
                      "Appreciate molecular complexity",
                      "Develop synthetic creativity",
                      "Enhance safety consciousness"
                    ]
                  },
                  "weeks": [
                    {
                      "weekNumber": 1,
                      "topic": "Organic Functional Groups and Nomenclature",
                      "overview": "Systematic naming of organic compounds, recognition of functional groups, and introduction to basic reaction types.",
                      "coreCompetencies": [
                        "Naming organic compounds",
                        "Identifying functional groups",
                        "Predicting basic reactivity"
                      ],
                      "scholonStandard": "Scholon Advanced Level",
                      "notes": [
                        {
                          "id": "CHE001_T2_W1_N1",
                          "title": "IUPAC Nomenclature",
                          "content": "Systematic naming of alkanes, alkenes, alkynes, and functional group derivatives. Priority rules, numbering, and stereochemical designations.",
                          "duration": "60 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["IUPAC rules", "Parent chain", "Substituents", "Functional group priority"],
                          "learningTags": ["nomenclature", "organic", "IUPAC"],
                          "contentType": "theory",
                          "references": []
                        },
                        {
                          "id": "CHE001_T2_W1_N2",
                          "title": "Functional Group Characteristics",
                          "content": "Properties and characteristic reactions of major functional groups: alcohols, aldehydes, ketones, carboxylic acids, amines, etc.",
                          "duration": "60 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Functional groups", "Reactivity patterns", "Characteristic reactions"],
                          "learningTags": ["functional_groups", "organic", "reactivity"],
                          "contentType": "theory",
                          "references": []
                        }
                      ],
                      "quizzes": [
                        {
                          "id": "CHE001_T2_W1_Q1",
                          "title": "Organic Nomenclature Quiz",
                          "description": "Test ability to name organic compounds and identify functional groups",
                          "questions": [
                            {
                              "id": "CHE001_T2_W1_Q1_Q1",
                              "question": "Name the compound: CH₃CH₂CH(OH)CH₃",
                              "options": [
                                {"id": "A", "text": "1-butanol", "isCorrect": false},
                                {"id": "B", "text": "2-butanol", "isCorrect": true},
                                {"id": "C", "text": "2-methyl-1-propanol", "isCorrect": false},
                                {"id": "D", "text": "Butan-2-ol", "isCorrect": true}
                              ],
                              "correctAnswer": 1,
                              "explanation": "4-carbon chain with OH on carbon 2 → 2-butanol or butan-2-ol",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["nomenclature", "alcohols", "IUPAC"]
                            },
                            {
                              "id": "CHE001_T2_W1_Q1_Q2",
                              "question": "Which functional group is most oxidized?",
                              "options": [
                                {"id": "A", "text": "Alcohol", "isCorrect": false},
                                {"id": "B", "text": "Aldehyde", "isCorrect": false},
                                {"id": "C", "text": "Ketone", "isCorrect": false},
                                {"id": "D", "text": "Carboxylic acid", "isCorrect": true}
                              ],
                              "correctAnswer": 3,
                              "explanation": "Oxidation states: alkane < alcohol < aldehyde/ketone < carboxylic acid",
                              "scholonBloomLevel": "Understand",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["functional_groups", "oxidation", "reactivity"]
                            }
                          ],
                          "duration": 25,
                          "passingScore": 70,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "formative"
                        }
                      ],
                      "assignments": [
                        {
                          "id": "CHE001_T2_W1_A1",
                          "title": "Functional Group Identification Project",
                          "type": "project",
                          "description": "Create a comprehensive guide to organic functional groups including structures, properties, characteristic reactions, and spectroscopic signatures.",
                          "requirements": [
                            "Cover 15 major functional groups",
                            "Include structural formulas",
                            "List characteristic reactions",
                            "Provide spectroscopic data (IR, NMR)",
                            "Include real-world examples"
                          ],
                          "submissionFormat": "Digital reference guide or poster",
                          "deadline": "2 weeks",
                          "totalPoints": 80,
                          "submissionCriteria": [
                            {
                              "criterion": "Comprehensiveness",
                              "maxPoints": 30,
                              "description": "Coverage of required functional groups and information"
                            },
                            {
                              "criterion": "Accuracy",
                              "maxPoints": 30,
                              "description": "Correct information and structures"
                            },
                            {
                              "criterion": "Presentation",
                              "maxPoints": 20,
                              "description": "Clarity, organization, and visual appeal"
                            }
                          ],
                          "difficulty": "Intermediate",
                          "skillsDeveloped": ["organic chemistry", "information synthesis", "visual communication", "reference creation"]
                        }
                      ],
                      "exams": {
                        "id": "CHE001_T2_W1_EXAM",
                        "papers": [],
                        "metadata": {
                          "totalPapers": 0,
                          "totalQuestions": 0,
                          "totalMarks": 0,
                          "examFormat": "No exam this week",
                          "gradingPolicy": "N/A"
                        }
                      },
                      "activities": [
                        {
                          "id": "CHE001_T2_W1_ACT1",
                          "title": "Molecular Model Building",
                          "type": "hands_on",
                          "description": "Build physical molecular models of organic compounds with different functional groups. Explore three-dimensional structures and stereochemistry.",
                          "duration": "90 minutes",
                          "materialsNeeded": ["Molecular model kits", "Worksheets", "Reference charts"],
                          "learningOutcome": "Develop spatial understanding of molecular structures and stereochemical concepts",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Introduction to molecular model kits",
                              "timeAllocation": "15 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Building simple hydrocarbons",
                              "timeAllocation": "25 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Building functionalized molecules",
                              "timeAllocation": "35 minutes"
                            },
                            {
                              "stepNumber": 4,
                              "instruction": "Exploring stereoisomers",
                              "timeAllocation": "15 minutes"
                            }
                          ]
                        }
                      ]
                    }
                  ]
                },
                {
                  "id": "CHE001_T3",
                  "term": "Third Term",
                  "duration": "April - July",
                  "focus": "Inorganic Chemistry and Analytical Methods",
                  "objectives": {
                    "knowledgeObjectives": [
                      "Understand coordination chemistry",
                      "Master analytical techniques",
                      "Learn environmental chemistry"
                    ],
                    "skillObjectives": [
                      "Analyze chemical samples",
                      "Use instrumental methods",
                      "Solve environmental problems"
                    ],
                    "attitudeObjectives": [
                      "Appreciate chemical analysis",
                      "Develop environmental awareness",
                      "Enhance quality control mindset"
                    ]
                  },
                  "weeks": [
                    {
                      "weekNumber": 1,
                      "topic": "Coordination Chemistry Fundamentals",
                      "overview": "Introduction to coordination compounds: ligands, coordination numbers, isomerism, and bonding theories.",
                      "coreCompetencies": [
                        "Naming coordination compounds",
                        "Identifying isomerism",
                        "Understanding crystal field theory"
                      ],
                      "scholonStandard": "Scholon Advanced Level",
                      "notes": [
                        {
                          "id": "CHE001_T3_W1_N1",
                          "title": "Coordination Compounds and Nomenclature",
                          "content": "Werner's theory, ligands, coordination numbers, and IUPAC naming of coordination compounds. Chelates and polydentate ligands.",
                          "duration": "60 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Coordination compounds", "Ligands", "Chelation", "IUPAC naming"],
                          "learningTags": ["coordination", "inorganic", "nomenclature"],
                          "contentType": "theory",
                          "references": []
                        },
                        {
                          "id": "CHE001_T3_W1_N2",
                          "title": "Isomerism in Coordination Compounds",
                          "content": "Structural isomerism (coordination, linkage, hydrate, ionization) and stereoisomerism (geometric, optical). Examples and identification methods.",
                          "duration": "60 min",
                          "difficulty": "Advanced",
                          "keyConcepts": ["Isomerism", "Geometric isomers", "Optical isomers", "Chirality"],
                          "learningTags": ["isomerism", "coordination", "stereochemistry"],
                          "contentType": "theory",
                          "references": []
                        }
                      ],
                      "quizzes": [
                        {
                          "id": "CHE001_T3_W1_Q1",
                          "title": "Coordination Chemistry Quiz",
                          "description": "Test understanding of coordination compound fundamentals",
                          "questions": [
                            {
                              "id": "CHE001_T3_W1_Q1_Q1",
                              "question": "Name the compound: [Co(NH₃)₅Cl]Cl₂",
                              "options": [
                                {"id": "A", "text": "Pentaamminechlorocobalt(III) chloride", "isCorrect": true},
                                {"id": "B", "text": "Chloropentaamminecobalt(II) chloride", "isCorrect": false},
                                {"id": "C", "text": "Cobalt pentaammine chloride", "isCorrect": false},
                                {"id": "D", "text": "Pentaamminecobalt(III) dichloride", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "Coordination sphere: pentaamminechloro, metal: cobalt, oxidation state: III (from charges: Cl in sphere -1, 5NH₃ neutral, total -1, so Co must be +3 to balance), counter ions: chloride",
                              "scholonBloomLevel": "Apply",
                              "points": 4,
                              "questionType": "multiple_choice",
                              "tags": ["nomenclature", "coordination", "IUPAC"]
                            },
                            {
                              "id": "CHE001_T3_W1_Q1_Q2",
                              "question": "How many geometric isomers exist for [Ma₂b₂] square planar?",
                              "options": [
                                {"id": "A", "text": "1", "isCorrect": false},
                                {"id": "B", "text": "2", "isCorrect": true},
                                {"id": "C", "text": "3", "isCorrect": false},
                                {"id": "D", "text": "4", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "Square planar Ma₂b₂ has cis and trans isomers",
                              "scholonBloomLevel": "Remember",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["isomerism", "geometric", "square_planar"]
                            }
                          ],
                          "duration": 25,
                          "passingScore": 70,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "formative"
                        }
                      ],
                      "assignments": [
                        {
                          "id": "CHE001_T3_W1_A1",
                          "title": "Coordination Compound Synthesis and Analysis",
                          "type": "lab_report",
                          "description": "Synthesize a coordination compound (e.g., copper complex), purify it, and characterize using analytical techniques. Determine composition and properties.",
                          "requirements": [
                            "Synthesis procedure",
                            "Purification methods",
                            "Yield calculation",
                            "Analytical characterization",
                            "Structure determination"
                          ],
                          "submissionFormat": "Complete lab report with data",
                          "deadline": "2 weeks",
                          "totalPoints": 90,
                          "submissionCriteria": [
                            {
                              "criterion": "Experimental Skill",
                              "maxPoints": 30,
                              "description": "Quality of synthesis and purification"
                            },
                            {
                              "criterion": "Analytical Accuracy",
                              "maxPoints": 30,
                              "description": "Accuracy of characterization and calculations"
                            },
                            {
                              "criterion": "Report Quality",
                              "maxPoints": 30,
                              "description": "Completeness and clarity of report"
                            }
                          ],
                          "difficulty": "Advanced",
                          "skillsDeveloped": ["synthesis", "analytical chemistry", "coordination chemistry", "lab techniques"]
                        }
                      ],
                      "exams": {
                        "id": "CHE001_T3_W1_EXAM",
                        "papers": [],
                        "metadata": {
                          "totalPapers": 0,
                          "totalQuestions": 0,
                          "totalMarks": 0,
                          "examFormat": "No exam this week",
                          "gradingPolicy": "N/A"
                        }
                      },
                      "activities": [
                        {
                          "id": "CHE001_T3_W1_ACT1",
                          "title": "Crystal Field Theory Workshop",
                          "type": "workshop",
                          "description": "Interactive workshop exploring crystal field theory. Calculate crystal field splitting, predict magnetic properties, and interpret electronic spectra.",
                          "duration": "90 minutes",
                          "materialsNeeded": ["Molecular models", "Spectroscopic data", "Worksheets", "Calculators"],
                          "learningOutcome": "Develop understanding of bonding in coordination compounds and spectroscopic interpretation",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Introduction to crystal field theory",
                              "timeAllocation": "25 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Calculating Δ and pairing energy",
                              "timeAllocation": "30 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Interpreting electronic spectra",
                              "timeAllocation": "35 minutes"
                            }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ],
          "assessmentStructure": {
            "continuousAssessment": 40,
            "termlyExaminations": 60,
            "gradingScale": {
              "A+": "95-100%",
              "A": "90-94%",
              "A-": "85-89%",
              "B+": "80-84%",
              "B": "75-79%",
              "B-": "70-74%",
              "C+": "65-69%",
              "C": "60-64%",
              "D": "50-59%",
              "F": "Below 50%"
            },
            "weightDistribution": {
              "quizzes": 15,
              "assignments": 25,
              "midterm": 20,
              "final": 40
            }
          },
          "learningOutcomes": {
            "cognitiveSkills": [
              "Critical thinking and advanced problem-solving at university level",
              "Research methodology and academic writing proficiency",
              "Analytical reasoning and quantitative analysis skills",
              "Scientific inquiry and experimental design capabilities",
              "Synthesis of interdisciplinary knowledge"
            ],
            "practicalSkills": [
              "Advanced laboratory techniques and safety protocols",
              "Data analysis and statistical inference using software tools",
              "Research project management and execution",
              "Academic presentation and scientific communication",
              "Digital literacy and technology integration"
            ],
            "softSkills": [
              "Collaboration and teamwork in academic settings",
              "Time management and organizational skills",
              "Digital literacy and ethical technology use",
              "Ethical reasoning and social responsibility",
              "Adaptability and lifelong learning mindset"
            ],
            "scholonCompetencies": [
              "Scholon Advanced Problem Solver - ability to tackle complex, multi-step problems",
              "Scholon Research Scholar - capability to conduct independent academic research",
              "Scholon Digital Innovator - proficiency with modern educational technology",
              "Scholon Global Citizen - understanding of global issues and diverse perspectives",
              "Scholon Communicator - effective written and oral communication skills"
            ]
          },
          "resources": {
            "textbooks": [
              {
                "title": "Scholon Advanced Mathematics Textbook",
                "url": "https://scholon.com/books/advanced-math",
                "type": "textbook",
                "description": "Comprehensive textbook covering all SS3 mathematics topics with worked examples and exercises",
                "accessType": "free",
                "format": "pdf"
              },
              {
                "title": "University Physics with Modern Physics",
                "url": "https://scholon.com/books/university-physics",
                "type": "textbook",
                "description": "Standard university-level physics textbook adapted for Scholon curriculum",
                "accessType": "subscription",
                "format": "epub"
              },
              {
                "title": "Advanced Chemistry: Principles and Applications",
                "url": "https://scholon.com/books/advanced-chemistry",
                "type": "textbook",
                "description": "Comprehensive chemistry textbook covering organic, inorganic, and physical chemistry",
                "accessType": "subscription",
                "format": "pdf"
              },
              {
                "title": "Biology: The Dynamic Science",
                "url": "https://scholon.com/books/biology-dynamic-science",
                "type": "textbook",
                "description": "Modern biology textbook with emphasis on molecular biology and genetics",
                "accessType": "free",
                "format": "epub"
              }
            ],
            "digitalResources": [
              {
                "title": "Scholon Learning Platform",
                "url": "https://learn.scholon.com",
                "type": "platform",
                "description": "Interactive learning platform with videos, simulations, and adaptive exercises",
                "accessType": "subscription",
                "format": "interactive"
              },
              {
                "title": "Khan Academy Advanced Courses",
                "url": "https://scholon.com/resources/khan-academy",
                "type": "video_course",
                "description": "Curated collection of advanced mathematics and science video tutorials",
                "accessType": "free",
                "format": "video"
              },
              {
                "title": "Wolfram Alpha Pro",
                "url": "https://scholon.com/tools/wolfram",
                "type": "tool",
                "description": "Computational knowledge engine for mathematics and science",
                "accessType": "institutional",
                "format": "web_app"
              },
              {
                "title": "PhET Interactive Simulations",
                "url": "https://scholon.com/simulations/phet",
                "type": "simulation",
                "description": "Interactive science and mathematics simulations from University of Colorado",
                "accessType": "free",
                "format": "interactive"
              },
              {
                "title": "JSTOR Academic Journals",
                "url": "https://scholon.com/resources/jstor",
                "type": "database",
                "description": "Access to academic journals and research papers across disciplines",
                "accessType": "institutional",
                "format": "database"
              },
              {
                "title": "Codecademy Pro",
                "url": "https://scholon.com/tools/codecademy",
                "type": "learning_platform",
                "description": "Interactive programming courses for computer science students",
                "accessType": "subscription",
                "format": "interactive"
              }
            ],
            "laboratoryEquipment": [
              {
                "name": "Scholon Advanced Physics Laboratory Kit",
                "description": "Complete set for advanced physics experiments including optics, electronics, and mechanics modules",
                "quantity": 15,
                "specifications": "Includes oscilloscopes, function generators, optics bench, sensors, and data loggers",
                "safetyLevel": "Level 2 - Requires supervision"
              },
              {
                "name": "Chemistry Analytical Instruments",
                "description": "Set of analytical chemistry equipment including spectrophotometers and titration apparatus",
                "quantity": 10,
                "specifications": "UV-Vis spectrophotometer, pH meters, conductivity meters, analytical balances",
                "safetyLevel": "Level 2 - Chemical handling required"
              },
              {
                "name": "Biology Molecular Biology Kit",
                "description": "Equipment for molecular biology experiments including PCR and gel electrophoresis",
                "quantity": 12,
                "specifications": "Thermocycler, electrophoresis equipment, micropipettes, centrifuge",
                "safetyLevel": "Level 2 - Biological materials handling"
              },
              {
                "name": "Computer Science Robotics Kit",
                "description": "Advanced robotics kit for programming and automation projects",
                "quantity": 20,
                "specifications": "Microcontrollers, sensors, motors, programming interface",
                "safetyLevel": "Level 1 - Basic supervision"
              }
            ],
            "softwareTools": [
              {
                "name": "Scholon Code Studio",
                "version": "2.1.0",
                "purpose": "Integrated development environment with educational features for programming courses",
                "license": "Educational",
                "systemRequirements": "Windows 10+, macOS 10.14+, 8GB RAM, 5GB storage"
              },
              {
                "name": "GeoGebra Advanced",
                "version": "6.0",
                "purpose": "Dynamic mathematics software for geometry, algebra, and calculus",
                "license": "Free",
                "systemRequirements": "Web-based or desktop application"
              },
              {
                "name": "Jupyter Notebook",
                "version": "6.4",
                "purpose": "Interactive computing environment for data science and scientific computing",
                "license": "Open Source",
                "systemRequirements": "Python 3.8+, 4GB RAM"
              },
              {
                "name": "LaTeX Editor",
                "version": "Latest",
                "purpose": "Typesetting software for mathematical and scientific documents",
                "license": "Free",
                "systemRequirements": "Cross-platform, various editors available"
              },
              {
                "name": "R Studio",
                "version": "2023.03",
                "purpose": "Integrated development environment for R statistical computing",
                "license": "Open Source",
                "systemRequirements": "Windows/macOS/Linux, 4GB RAM"
              },
              {
                "name": "AutoCAD Educational",
                "version": "2024",
                "purpose": "Computer-aided design software for engineering and architecture projects",
                "license": "Educational",
                "systemRequirements": "Windows 10+, 8GB RAM, 10GB storage"
              }
            ]
          },
          "schedule": {
            "terms": [
              {
                "term": 1,
                "duration": "September - December",
                "weeks": 12,
                "startDate": "2023-09-04T00:00:00.000",
                "endDate": "2023-12-15T00:00:00.000",
                "holidays": ["Mid-term Break: October 9-13, 2023", "Thanksgiving: November 23-24, 2023"]
              },
              {
                "term": 2,
                "duration": "January - March",
                "weeks": 12,
                "startDate": "2024-01-08T00:00:00.000",
                "endDate": "2024-03-22T00:00:00.000",
                "holidays": ["Mid-term Break: February 12-16, 2024", "Presidents' Day: February 19, 2024"]
              },
              {
                "term": 3,
                "duration": "April - July",
                "weeks": 12,
                "startDate": "2024-04-08T00:00:00.000",
                "endDate": "2024-07-12T00:00:00.000",
                "holidays": ["Mid-term Break: May 27-31, 2024", "Memorial Day: May 27, 2024", "Independence Day: July 4, 2024"]
              }
            ],
            "totalWeeks": 36,
            "totalHours": 1440,
            "contactHoursPerWeek": 40,
            "startDate": "2023-09-04T00:00:00.000",
            "endDate": "2024-07-12T00:00:00.000",
            "importantDates": [
              "Orientation: September 1-3, 2023",
              "First Term Exams: December 11-15, 2023",
              "Second Term Exams: March 18-22, 2024",
              "Final Exams: July 8-12, 2024",
              "Graduation: July 13, 2024"
            ]
          },
          "policies": {
            "attendance": "Minimum 85% attendance required for examination eligibility",
            "academicIntegrity": "Zero tolerance for plagiarism; violations result in course failure",
            "assessment": "All assessments must be completed; missed exams require medical documentation",
            "technology": "Personal devices permitted for educational purposes only",
            "safety": "Strict adherence to laboratory safety protocols mandatory",
            "supportServices": [
              "Academic tutoring available Monday-Friday 3-5 PM",
              "Career counseling by appointment",
              "Mental health support services",
              "University application assistance"
            ]
          }
        }
      ]
''';

static const String ss2Curriculum = '''
      [
        {
          "curriculum": "Scholon Intermediate Curriculum",
          "academicYear": "2023/2024",
          "schoolLevel": "Senior Secondary 2 (SS2)",
          "courses": [
            {
              "id": "MAT002",
              "courseCode": "MAT",
              "name": "Intermediate Mathematics",
              "description": "Fundamental mathematical concepts including algebra, geometry, trigonometry, and introductory calculus",
              "strand": "STEM",
              "credits": 1.0,
              "scholonLevel": "Scholon Intermediate Level",
              "metadata": {
                "difficulty": "Intermediate",
                "prerequisites": ["SS1 Mathematics"],
                "targetAudience": "SS2 Students pursuing any field",
                "version": "2.0",
                "lastUpdated": "2023-08-15T00:00:00.000",
                "instructor": "Dr. Sarah Johnson",
                "department": "Mathematics"
              },
              "terms": [
                {
                  "id": "MAT002_T1",
                  "term": "First Term",
                  "duration": "September - December",
                  "focus": "Algebra and Functions",
                  "objectives": {
                    "knowledgeObjectives": [
                      "Master algebraic manipulation",
                      "Understand function concepts",
                      "Apply mathematical reasoning"
                    ],
                    "skillObjectives": [
                      "Solve complex equations",
                      "Analyze function behavior",
                      "Use graphing techniques"
                    ],
                    "attitudeObjectives": [
                      "Develop logical thinking",
                      "Cultivate mathematical confidence",
                      "Enhance problem-solving persistence"
                    ]
                  },
                  "weeks": [
                    {
                      "weekNumber": 1,
                      "topic": "Quadratic Equations and Functions",
                      "overview": "This week focuses on solving quadratic equations, analyzing quadratic functions, and understanding their graphical representations.",
                      "coreCompetencies": [
                        "Solving quadratic equations",
                        "Graphing parabolas",
                        "Applying quadratic formula",
                        "Analyzing vertex form"
                      ],
                      "scholonStandard": "Scholon Intermediate Level",
                      "notes": [
                        {
                          "id": "MAT002_W1_N1",
                          "title": "Quadratic Equation Forms",
                          "content": "Standard form (ax²+bx+c=0), factored form (a(x-r₁)(x-r₂)=0), and vertex form (a(x-h)²+k=0). Converting between forms and identifying key features.",
                          "duration": "50 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Standard form", "Factored form", "Vertex form", "Discriminant"],
                          "learningTags": ["quadratic", "algebra", "equations"],
                          "contentType": "theory",
                          "references": [
                            {
                              "title": "Algebra 2 Textbook",
                              "url": "https://scholon.com/ref/algebra2",
                              "type": "book"
                            }
                          ]
                        },
                        {
                          "id": "MAT002_W1_N2",
                          "title": "Quadratic Formula and Discriminant",
                          "content": "Derivation and application of quadratic formula: x = [-b ± √(b²-4ac)]/2a. Understanding discriminant (Δ = b²-4ac) and its significance for roots.",
                          "duration": "50 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Quadratic formula", "Discriminant", "Nature of roots", "Complex roots"],
                          "learningTags": ["quadratic", "formula", "roots"],
                          "contentType": "example",
                          "references": []
                        }
                      ],
                      "quizzes": [
                        {
                          "id": "MAT002_W1_Q1",
                          "title": "Quadratic Equations Quiz 1",
                          "description": "Test understanding of solving quadratic equations using various methods",
                          "questions": [
                            {
                              "id": "MAT002_W1_Q1_Q1",
                              "question": "Solve x² - 5x + 6 = 0",
                              "options": [
                                {"id": "A", "text": "x = 2, 3", "isCorrect": true},
                                {"id": "B", "text": "x = 1, 6", "isCorrect": false},
                                {"id": "C", "text": "x = -2, -3", "isCorrect": false},
                                {"id": "D", "text": "x = 2.5, 2.5", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "Factor: (x-2)(x-3)=0 → x=2 or x=3",
                              "scholonBloomLevel": "Apply",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["quadratic", "factoring"]
                            },
                            {
                              "id": "MAT002_W1_Q1_Q2",
                              "question": "What is the discriminant of x² + 4x + 4 = 0?",
                              "options": [
                                {"id": "A", "text": "0", "isCorrect": true},
                                {"id": "B", "text": "8", "isCorrect": false},
                                {"id": "C", "text": "16", "isCorrect": false},
                                {"id": "D", "text": "32", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "Δ = b²-4ac = 4²-4(1)(4) = 16-16 = 0",
                              "scholonBloomLevel": "Apply",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["discriminant", "quadratic"]
                            },
                            {
                              "id": "MAT002_W1_Q1_Q3",
                              "question": "Find vertex of parabola y = x² - 6x + 8",
                              "options": [
                                {"id": "A", "text": "(3, -1)", "isCorrect": true},
                                {"id": "B", "text": "(3, 1)", "isCorrect": false},
                                {"id": "C", "text": "(-3, -1)", "isCorrect": false},
                                {"id": "D", "text": "(-3, 1)", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "Complete square: y = (x-3)² - 1 → vertex (3, -1)",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["vertex", "parabola"]
                            },
                            {
                              "id": "MAT002_W1_Q1_Q4",
                              "question": "Using quadratic formula, solve 2x² - 4x - 6 = 0",
                              "options": [
                                {"id": "A", "text": "x = -1, 3", "isCorrect": true},
                                {"id": "B", "text": "x = 1, -3", "isCorrect": false},
                                {"id": "C", "text": "x = 2, -1.5", "isCorrect": false},
                                {"id": "D", "text": "x = -2, 1.5", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "x = [4 ± √(16+48)]/4 = [4 ± √64]/4 = [4 ± 8]/4 = 3 or -1",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["quadratic_formula", "solving"]
                            },
                            {
                              "id": "MAT002_W1_Q1_Q5",
                              "question": "Which quadratic has no real roots?",
                              "options": [
                                {"id": "A", "text": "x² + 4x + 4 = 0", "isCorrect": false},
                                {"id": "B", "text": "x² - 5x + 6 = 0", "isCorrect": false},
                                {"id": "C", "text": "x² + 2x + 5 = 0", "isCorrect": true},
                                {"id": "D", "text": "x² - 3x + 2 = 0", "isCorrect": false}
                              ],
                              "correctAnswer": 2,
                              "explanation": "Discriminant: 2²-4(1)(5)=4-20=-16 < 0 → no real roots",
                              "scholonBloomLevel": "Analyze",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["discriminant", "roots"]
                            }
                          ],
                          "duration": 25,
                          "passingScore": 70,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "formative"
                        }
                      ],
                      "assignments": [
                        {
                          "id": "MAT002_W1_A1",
                          "title": "Quadratic Functions Project",
                          "type": "project",
                          "description": "Investigate real-world applications of quadratic functions (projectile motion, area optimization, business profit). Create models and analyze solutions.",
                          "requirements": [
                            "3 real-world applications",
                            "Mathematical modeling",
                            "Graphical representations",
                            "Solution analysis",
                            "Written report"
                          ],
                          "submissionFormat": "PDF report with graphs and calculations",
                          "deadline": "2 weeks",
                          "totalPoints": 85,
                          "submissionCriteria": [
                            {
                              "criterion": "Application Relevance",
                              "maxPoints": 25,
                              "description": "Appropriateness of real-world applications"
                            },
                            {
                              "criterion": "Mathematical Accuracy",
                              "maxPoints": 30,
                              "description": "Correct modeling and calculations"
                            },
                            {
                              "criterion": "Analysis Depth",
                              "maxPoints": 20,
                              "description": "Depth of analysis and insights"
                            },
                            {
                              "criterion": "Presentation",
                              "maxPoints": 10,
                              "description": "Clarity and organization of report"
                            }
                          ],
                          "difficulty": "Intermediate",
                          "skillsDeveloped": ["mathematical modeling", "real-world applications", "graphing", "analysis"]
                        }
                      ],
                      "exams": {
                        "id": "MAT002_W1_EXAM",
                        "papers": [
                          {
                            "id": "MAT002_W1_P1",
                            "title": "Algebra Fundamentals Exam",
                            "examType": "mixed",
                            "questions": [
                              {
                                "id": "MAT002_W1_P1_Q1",
                                "question": "Solve the quadratic equation 3x² - 7x + 2 = 0",
                                "correctAnswer": "x = 2, 1/3",
                                "solutionSteps": "Use quadratic formula or factoring: (3x-1)(x-2)=0 → x=1/3 or x=2",
                                "marks": 5,
                                "scholonBloomLevel": "Apply",
                                "questionType": "short_answer"
                              },
                              {
                                "id": "MAT002_W1_P1_Q2",
                                "question": "Find the vertex and axis of symmetry for y = -2x² + 8x - 5",
                                "correctAnswer": "Vertex: (2, 3), Axis: x = 2",
                                "solutionSteps": "Complete square: y = -2(x²-4x) -5 = -2[(x-2)²-4] -5 = -2(x-2)²+8-5 = -2(x-2)²+3",
                                "marks": 6,
                                "scholonBloomLevel": "Apply",
                                "questionType": "short_answer"
                              }
                            ],
                            "duration": 90,
                            "totalMarks": 100,
                            "instructions": "Answer all questions. Show all working.",
                            "allowedMaterials": ["Calculator", "Ruler"]
                          }
                        ],
                        "metadata": {
                          "totalPapers": 1,
                          "totalQuestions": 20,
                          "totalMarks": 100,
                          "examFormat": "Mixed format",
                          "gradingPolicy": "Standard grading with partial marks"
                        }
                      },
                      "activities": [
                        {
                          "id": "MAT002_W1_ACT1",
                          "title": "Parabola Graphing Activity",
                          "type": "hands_on",
                          "description": "Use graphing calculators or software to explore how changes in a, b, and c affect parabola shape, position, and orientation.",
                          "duration": "60 minutes",
                          "materialsNeeded": ["Graphing calculators", "Graph paper", "Worksheets"],
                          "learningOutcome": "Develop intuitive understanding of quadratic function parameters",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Graph basic parabola y = x²",
                              "timeAllocation": "10 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Explore effect of changing 'a' coefficient",
                              "timeAllocation": "20 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Explore effect of changing 'b' and 'c'",
                              "timeAllocation": "20 minutes"
                            },
                            {
                              "stepNumber": 4,
                              "instruction": "Summarize findings",
                              "timeAllocation": "10 minutes"
                            }
                          ]
                        }
                      ]
                    },
                    {
                      "weekNumber": 2,
                      "topic": "Polynomial Functions",
                      "overview": "Study of polynomial functions including end behavior, zeros, multiplicity, and synthetic division.",
                      "coreCompetencies": [
                        "Analyzing polynomial graphs",
                        "Finding polynomial zeros",
                        "Applying remainder theorem",
                        "Understanding end behavior"
                      ],
                      "scholonStandard": "Scholon Intermediate Level",
                      "notes": [
                        {
                          "id": "MAT002_W2_N1",
                          "title": "Polynomial Basics",
                          "content": "Definition, degree, leading coefficient, standard form. End behavior based on degree and leading coefficient. Identifying turning points.",
                          "duration": "50 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Degree", "Leading coefficient", "End behavior", "Turning points"],
                          "learningTags": ["polynomials", "functions", "graphs"],
                          "contentType": "theory",
                          "references": []
                        },
                        {
                          "id": "MAT002_W2_N2",
                          "title": "Finding Zeros of Polynomials",
                          "content": "Rational root theorem, synthetic division, factoring techniques. Relationship between zeros and factors. Multiplicity of zeros.",
                          "duration": "50 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Zeros", "Synthetic division", "Rational root theorem", "Multiplicity"],
                          "learningTags": ["polynomials", "zeros", "factoring"],
                          "contentType": "theory",
                          "references": []
                        }
                      ],
                      "quizzes": [
                        {
                          "id": "MAT002_W2_Q1",
                          "title": "Polynomial Functions Quiz",
                          "description": "Test understanding of polynomial properties and operations",
                          "questions": [
                            {
                              "id": "MAT002_W2_Q1_Q1",
                              "question": "What is the degree of f(x) = 3x⁴ - 2x³ + x - 5?",
                              "options": [
                                {"id": "A", "text": "3", "isCorrect": false},
                                {"id": "B", "text": "4", "isCorrect": true},
                                {"id": "C", "text": "5", "isCorrect": false},
                                {"id": "D", "text": "6", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "Highest exponent is 4, so degree is 4",
                              "scholonBloomLevel": "Remember",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["degree", "polynomials"]
                            },
                            {
                              "id": "MAT002_W2_Q1_Q2",
                              "question": "Describe end behavior of f(x) = -2x³ + 3x - 1",
                              "options": [
                                {"id": "A", "text": "Up left, down right", "isCorrect": false},
                                {"id": "B", "text": "Down left, up right", "isCorrect": false},
                                {"id": "C", "text": "Up left, up right", "isCorrect": false},
                                {"id": "D", "text": "Down left, down right", "isCorrect": true}
                              ],
                              "correctAnswer": 3,
                              "explanation": "Odd degree (3) with negative leading coefficient (-2): as x→-∞, f(x)→∞; as x→∞, f(x)→-∞",
                              "scholonBloomLevel": "Analyze",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["end_behavior", "polynomials"]
                            }
                          ],
                          "duration": 25,
                          "passingScore": 70,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "formative"
                        }
                      ],
                      "assignments": [
                        {
                          "id": "MAT002_W2_A1",
                          "title": "Polynomial Analysis Portfolio",
                          "type": "portfolio",
                          "description": "Create a portfolio analyzing various polynomial functions. Include graphs, zero analysis, end behavior, and real-world applications.",
                          "requirements": [
                            "5 different polynomial functions",
                            "Complete graphical analysis",
                            "Zero finding with methods",
                            "Real-world context",
                            "Written explanations"
                          ],
                          "submissionFormat": "Digital portfolio",
                          "deadline": "10 days",
                          "totalPoints": 80,
                          "submissionCriteria": [
                            {
                              "criterion": "Mathematical Accuracy",
                              "maxPoints": 30,
                              "description": "Correct analysis and calculations"
                            },
                            {
                              "criterion": "Completeness",
                              "maxPoints": 25,
                              "description": "All required components included"
                            },
                            {
                              "criterion": "Presentation",
                              "maxPoints": 25,
                              "description": "Organization and clarity of portfolio"
                            }
                          ],
                          "difficulty": "Intermediate",
                          "skillsDeveloped": ["polynomial analysis", "graphing", "mathematical communication"]
                        }
                      ],
                      "exams": {
                        "id": "MAT002_W2_EXAM",
                        "papers": [],
                        "metadata": {
                          "totalPapers": 0,
                          "totalQuestions": 0,
                          "totalMarks": 0,
                          "examFormat": "No exam this week",
                          "gradingPolicy": "N/A"
                        }
                      },
                      "activities": [
                        {
                          "id": "MAT002_W2_ACT1",
                          "title": "Synthetic Division Workshop",
                          "type": "workshop",
                          "description": "Hands-on practice with synthetic division technique. Learn efficient method for polynomial division and evaluating polynomials.",
                          "duration": "60 minutes",
                          "materialsNeeded": ["Worksheets", "Calculators", "Whiteboards"],
                          "learningOutcome": "Master synthetic division technique for polynomial operations",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Introduction to synthetic division",
                              "timeAllocation": "15 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Guided practice problems",
                              "timeAllocation": "30 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Independent practice and checking",
                              "timeAllocation": "15 minutes"
                            }
                          ]
                        }
                      ]
                    }
                  ]
                },
                {
                  "id": "MAT002_T2",
                  "term": "Second Term",
                  "duration": "January - March",
                  "focus": "Geometry and Trigonometry",
                  "objectives": {
                    "knowledgeObjectives": [
                      "Master geometric proofs",
                      "Understand trigonometric functions",
                      "Apply similarity concepts"
                    ],
                    "skillObjectives": [
                      "Solve geometric problems",
                      "Apply trigonometric ratios",
                      "Use coordinate geometry"
                    ],
                    "attitudeObjectives": [
                      "Appreciate geometric beauty",
                      "Develop spatial reasoning",
                      "Enhance deductive thinking"
                    ]
                  },
                  "weeks": [
                    {
                      "weekNumber": 1,
                      "topic": "Triangle Properties and Congruence",
                      "overview": "Properties of triangles, congruence postulates, and proofs. Applications to problem solving.",
                      "coreCompetencies": [
                        "Applying congruence postulates",
                        "Writing geometric proofs",
                        "Solving triangle problems"
                      ],
                      "scholonStandard": "Scholon Intermediate Level",
                      "notes": [
                        {
                          "id": "MAT002_T2_W1_N1",
                          "title": "Triangle Congruence Postulates",
                          "content": "SSS, SAS, ASA, AAS, and HL congruence theorems. Conditions for triangle congruence and applications in proofs.",
                          "duration": "50 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["SSS", "SAS", "ASA", "AAS", "HL"],
                          "learningTags": ["triangles", "congruence", "geometry"],
                          "contentType": "theory",
                          "references": []
                        },
                        {
                          "id": "MAT002_T2_W1_N2",
                          "title": "Geometric Proofs",
                          "content": "Structure of two-column proofs. Logical reasoning and justification. Common proof strategies for triangle congruence.",
                          "duration": "50 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Two-column proof", "Logical reasoning", "Justification"],
                          "learningTags": ["proofs", "geometry", "logic"],
                          "contentType": "theory",
                          "references": []
                        }
                      ],
                      "quizzes": [
                        {
                          "id": "MAT002_T2_W1_Q1",
                          "title": "Triangle Congruence Quiz",
                          "description": "Test understanding of triangle congruence and proof concepts",
                          "questions": [
                            {
                              "id": "MAT002_T2_W1_Q1_Q1",
                              "question": "Which postulate proves these triangles congruent? Given: AB=DE, BC=EF, ∠B=∠E",
                              "options": [
                                {"id": "A", "text": "SSS", "isCorrect": false},
                                {"id": "B", "text": "SAS", "isCorrect": true},
                                {"id": "C", "text": "ASA", "isCorrect": false},
                                {"id": "D", "text": "AAS", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "Two sides and included angle: SAS",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["congruence", "SAS", "triangles"]
                            }
                          ],
                          "duration": 25,
                          "passingScore": 70,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "formative"
                        }
                      ],
                      "assignments": [
                        {
                          "id": "MAT002_T2_W1_A1",
                          "title": "Geometric Proof Portfolio",
                          "type": "portfolio",
                          "description": "Create a collection of geometric proofs demonstrating various congruence theorems and proof techniques.",
                          "requirements": [
                            "5 different proofs",
                            "Use of different congruence postulates",
                            "Clear two-column format",
                            "Written explanations",
                            "Creative problem solutions"
                          ],
                          "submissionFormat": "PDF portfolio",
                          "deadline": "2 weeks",
                          "totalPoints": 75,
                          "submissionCriteria": [
                            {
                              "criterion": "Logical Correctness",
                              "maxPoints": 30,
                              "description": "Correct logical reasoning and justification"
                            },
                            {
                              "criterion": "Completeness",
                              "maxPoints": 25,
                              "description": "All required proofs with proper format"
                            },
                            {
                              "criterion": "Clarity",
                              "maxPoints": 20,
                              "description": "Clear presentation and explanation"
                            }
                          ],
                          "difficulty": "Intermediate",
                          "skillsDeveloped": ["geometric proof", "logical reasoning", "mathematical communication"]
                        }
                      ],
                      "exams": {
                        "id": "MAT002_T2_W1_EXAM",
                        "papers": [],
                        "metadata": {
                          "totalPapers": 0,
                          "totalQuestions": 0,
                          "totalMarks": 0,
                          "examFormat": "No exam this week",
                          "gradingPolicy": "N/A"
                        }
                      },
                      "activities": [
                        {
                          "id": "MAT002_T2_W1_ACT1",
                          "title": "Geometric Construction Lab",
                          "type": "lab",
                          "description": "Use compass and straightedge to construct triangles with given conditions and verify congruence experimentally.",
                          "duration": "90 minutes",
                          "materialsNeeded": ["Compasses", "Rulers", "Protractors", "Paper", "Measuring tools"],
                          "learningOutcome": "Develop geometric construction skills and hands-on understanding of congruence",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Review construction techniques",
                              "timeAllocation": "15 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Construct triangles with given conditions",
                              "timeAllocation": "45 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Measure and verify congruence",
                              "timeAllocation": "20 minutes"
                            },
                            {
                              "stepNumber": 4,
                              "instruction": "Discuss findings",
                              "timeAllocation": "10 minutes"
                            }
                          ]
                        }
                      ]
                    }
                  ]
                },
                {
                  "id": "MAT002_T3",
                  "term": "Third Term",
                  "duration": "April - July",
                  "focus": "Statistics and Probability",
                  "objectives": {
                    "knowledgeObjectives": [
                      "Understand statistical measures",
                      "Master probability concepts",
                      "Learn data analysis methods"
                    ],
                    "skillObjectives": [
                      "Analyze data sets",
                      "Calculate probabilities",
                      "Interpret statistical results"
                    ],
                    "attitudeObjectives": [
                      "Appreciate data literacy",
                      "Develop critical evaluation",
                      "Enhance evidence-based thinking"
                    ]
                  },
                  "weeks": [
                    {
                      "weekNumber": 1,
                      "topic": "Descriptive Statistics",
                      "overview": "Measures of central tendency and dispersion. Data representation and interpretation.",
                      "coreCompetencies": [
                        "Calculating statistical measures",
                        "Creating data visualizations",
                        "Interpreting statistical results"
                      ],
                      "scholonStandard": "Scholon Intermediate Level",
                      "notes": [
                        {
                          "id": "MAT002_T3_W1_N1",
                          "title": "Measures of Central Tendency",
                          "content": "Mean, median, mode calculations and interpretations. Appropriate use of each measure in different contexts.",
                          "duration": "50 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Mean", "Median", "Mode", "Central tendency"],
                          "learningTags": ["statistics", "central_tendency", "data_analysis"],
                          "contentType": "theory",
                          "references": []
                        },
                        {
                          "id": "MAT002_T3_W1_N2",
                          "title": "Measures of Dispersion",
                          "content": "Range, interquartile range, variance, standard deviation. Understanding data spread and variability.",
                          "duration": "50 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Range", "Standard deviation", "Variance", "Dispersion"],
                          "learningTags": ["statistics", "dispersion", "variability"],
                          "contentType": "theory",
                          "references": []
                        }
                      ],
                      "quizzes": [
                        {
                          "id": "MAT002_T3_W1_Q1",
                          "title": "Descriptive Statistics Quiz",
                          "description": "Test understanding of basic statistical measures",
                          "questions": [
                            {
                              "id": "MAT002_T3_W1_Q1_Q1",
                              "question": "Find mean of data: 5, 7, 9, 11, 13",
                              "options": [
                                {"id": "A", "text": "7", "isCorrect": false},
                                {"id": "B", "text": "8", "isCorrect": false},
                                {"id": "C", "text": "9", "isCorrect": true},
                                {"id": "D", "text": "10", "isCorrect": false}
                              ],
                              "correctAnswer": 2,
                              "explanation": "Mean = (5+7+9+11+13)/5 = 45/5 = 9",
                              "scholonBloomLevel": "Apply",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["mean", "statistics"]
                            },
                            {
                              "id": "MAT002_T3_W1_Q1_Q2",
                              "question": "What is range of data: 2, 5, 8, 12, 15?",
                              "options": [
                                {"id": "A", "text": "10", "isCorrect": false},
                                {"id": "B", "text": "13", "isCorrect": true},
                                {"id": "C", "text": "15", "isCorrect": false},
                                {"id": "D", "text": "17", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "Range = max - min = 15 - 2 = 13",
                              "scholonBloomLevel": "Apply",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["range", "statistics"]
                            }
                          ],
                          "duration": 25,
                          "passingScore": 70,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "formative"
                        }
                      ],
                      "assignments": [
                        {
                          "id": "MAT002_T3_W1_A1",
                          "title": "Data Analysis Project",
                          "type": "project",
                          "description": "Collect and analyze real data from your school or community. Calculate statistical measures and create visual representations.",
                          "requirements": [
                            "Data collection plan",
                            "Statistical calculations",
                            "Data visualizations",
                            "Interpretation of results",
                            "Written report"
                          ],
                          "submissionFormat": "Report with charts and analysis",
                          "deadline": "2 weeks",
                          "totalPoints": 85,
                          "submissionCriteria": [
                            {
                              "criterion": "Data Quality",
                              "maxPoints": 20,
                              "description": "Appropriateness and quality of collected data"
                            },
                            {
                              "criterion": "Analysis Accuracy",
                              "maxPoints": 30,
                              "description": "Correct statistical calculations and interpretations"
                            },
                            {
                              "criterion": "Visualization Quality",
                              "maxPoints": 20,
                              "description": "Effectiveness of data visualizations"
                            },
                            {
                              "criterion": "Insightful Conclusions",
                              "maxPoints": 15,
                              "description": "Depth of analysis and meaningful conclusions"
                            }
                          ],
                          "difficulty": "Intermediate",
                          "skillsDeveloped": ["data analysis", "statistics", "data visualization", "research"]
                        }
                      ],
                      "exams": {
                        "id": "MAT002_T3_W1_EXAM",
                        "papers": [],
                        "metadata": {
                          "totalPapers": 0,
                          "totalQuestions": 0,
                          "totalMarks": 0,
                          "examFormat": "No exam this week",
                          "gradingPolicy": "N/A"
                        }
                      },
                      "activities": [
                        {
                          "id": "MAT002_T3_W1_ACT1",
                          "title": "Statistical Software Workshop",
                          "type": "workshop",
                          "description": "Introduction to statistical software (Excel, Google Sheets, or basic R) for data analysis and visualization.",
                          "duration": "90 minutes",
                          "materialsNeeded": ["Computers with software", "Sample datasets", "Worksheets"],
                          "learningOutcome": "Develop basic proficiency with statistical software tools",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Software interface overview",
                              "timeAllocation": "20 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Basic statistical calculations",
                              "timeAllocation": "35 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Creating charts and graphs",
                              "timeAllocation": "35 minutes"
                            }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "id": "PHY002",
              "courseCode": "PHY",
              "name": "Intermediate Physics",
              "description": "Foundational physics concepts including mechanics, waves, and basic electricity",
              "strand": "STEM",
              "credits": 1.0,
              "scholonLevel": "Scholon Intermediate Level",
              "metadata": {
                "difficulty": "Intermediate",
                "prerequisites": ["SS1 Physics", "SS1 Mathematics"],
                "targetAudience": "SS2 Students pursuing sciences or engineering",
                "version": "2.0",
                "lastUpdated": "2023-08-15T00:00:00.000",
                "instructor": "Prof. Michael Chen",
                "department": "Physics"
              },
              "terms": [
                {
                  "id": "PHY002_T1",
                  "term": "First Term",
                  "duration": "September - December",
                  "focus": "Mechanics and Motion",
                  "objectives": {
                    "knowledgeObjectives": [
                      "Understand Newton's laws",
                      "Master kinematics equations",
                      "Learn energy concepts"
                    ],
                    "skillObjectives": [
                      "Solve motion problems",
                      "Analyze forces",
                      "Apply conservation laws"
                    ],
                    "attitudeObjectives": [
                      "Appreciate physical principles",
                      "Develop experimental skills",
                      "Enhance analytical thinking"
                    ]
                  },
                  "weeks": [
                    {
                      "weekNumber": 1,
                      "topic": "Linear Motion and Kinematics",
                      "overview": "Introduction to one-dimensional motion concepts: displacement, velocity, acceleration, and kinematic equations.",
                      "coreCompetencies": [
                        "Applying kinematic equations",
                        "Interpreting motion graphs",
                        "Solving velocity/acceleration problems"
                      ],
                      "scholonStandard": "Scholon Intermediate Level",
                      "notes": [
                        {
                          "id": "PHY002_W1_N1",
                          "title": "Kinematic Equations",
                          "content": "Derivation and application of four kinematic equations for constant acceleration. Problem-solving strategies for motion in one dimension.",
                          "duration": "50 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Displacement", "Velocity", "Acceleration", "Kinematic equations"],
                          "learningTags": ["kinematics", "motion", "equations"],
                          "contentType": "theory",
                          "references": []
                        },
                        {
                          "id": "PHY002_W1_N2",
                          "title": "Motion Graphs",
                          "content": "Interpretation of position-time, velocity-time, and acceleration-time graphs. Slope and area calculations for motion analysis.",
                          "duration": "50 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Position-time graph", "Velocity-time graph", "Slope", "Area under curve"],
                          "learningTags": ["motion", "graphs", "analysis"],
                          "contentType": "theory",
                          "references": []
                        }
                      ],
                      "quizzes": [
                        {
                          "id": "PHY002_W1_Q1",
                          "title": "Kinematics Fundamentals Quiz",
                          "description": "Test understanding of basic motion concepts and equations",
                          "questions": [
                            {
                              "id": "PHY002_W1_Q1_Q1",
                              "question": "A car accelerates from 20 m/s to 30 m/s in 5 seconds. What is acceleration?",
                              "options": [
                                {"id": "A", "text": "1 m/s²", "isCorrect": false},
                                {"id": "B", "text": "2 m/s²", "isCorrect": true},
                                {"id": "C", "text": "5 m/s²", "isCorrect": false},
                                {"id": "D", "text": "10 m/s²", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "a = Δv/Δt = (30-20)/5 = 10/5 = 2 m/s²",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["acceleration", "kinematics"]
                            },
                            {
                              "id": "PHY002_W1_Q1_Q2",
                              "question": "What does slope of position-time graph represent?",
                              "options": [
                                {"id": "A", "text": "Acceleration", "isCorrect": false},
                                {"id": "B", "text": "Velocity", "isCorrect": true},
                                {"id": "C", "text": "Displacement", "isCorrect": false},
                                {"id": "D", "text": "Distance", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "Slope = rise/run = Δposition/Δtime = velocity",
                              "scholonBloomLevel": "Understand",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["graphs", "motion", "interpretation"]
                            }
                          ],
                          "duration": 25,
                          "passingScore": 70,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "formative"
                        }
                      ],
                      "assignments": [
                        {
                          "id": "PHY002_W1_A1",
                          "title": "Motion Analysis Lab Report",
                          "type": "lab_report",
                          "description": "Experimental analysis of motion using ticker timers or motion sensors. Measure and analyze velocity and acceleration.",
                          "requirements": [
                            "Experimental procedure",
                            "Data collection and recording",
                            "Graphical analysis",
                            "Calculations and error analysis",
                            "Conclusions"
                          ],
                          "submissionFormat": "Formal lab report",
                          "deadline": "10 days",
                          "totalPoints": 80,
                          "submissionCriteria": [
                            {
                              "criterion": "Experimental Skill",
                              "maxPoints": 25,
                              "description": "Quality of experimental procedure and data collection"
                            },
                            {
                              "criterion": "Data Analysis",
                              "maxPoints": 30,
                              "description": "Accuracy of calculations and graphical analysis"
                            },
                            {
                              "criterion": "Report Quality",
                              "maxPoints": 25,
                              "description": "Clarity, organization, and scientific communication"
                            }
                          ],
                          "difficulty": "Intermediate",
                          "skillsDeveloped": ["experimental physics", "data analysis", "lab techniques", "scientific reporting"]
                        }
                      ],
                      "exams": {
                        "id": "PHY002_W1_EXAM",
                        "papers": [
                          {
                            "id": "PHY002_W1_P1",
                            "title": "Motion and Kinematics Exam",
                            "examType": "mixed",
                            "questions": [
                              {
                                "id": "PHY002_W1_P1_Q1",
                                "question": "A ball is dropped from 45m height. Calculate time to hit ground and final velocity.",
                                "correctAnswer": "t = 3.03 s, v = 29.7 m/s",
                                "solutionSteps": "Use h = ½gt² → 45 = 4.9t² → t²=9.18 → t=3.03s. v = gt = 9.8×3.03 = 29.7 m/s",
                                "marks": 8,
                                "scholonBloomLevel": "Apply",
                                "questionType": "calculation"
                              }
                            ],
                            "duration": 90,
                            "totalMarks": 100,
                            "instructions": "Answer all questions. Show all working.",
                            "allowedMaterials": ["Calculator", "Formula sheet"]
                          }
                        ],
                        "metadata": {
                          "totalPapers": 1,
                          "totalQuestions": 15,
                          "totalMarks": 100,
                          "examFormat": "Mixed format",
                          "gradingPolicy": "Standard grading"
                        }
                      },
                      "activities": [
                        {
                          "id": "PHY002_W1_ACT1",
                          "title": "Motion Sensor Lab",
                          "type": "lab",
                          "description": "Use motion sensors and data loggers to measure and analyze different types of motion: constant velocity, constant acceleration, free fall.",
                          "duration": "90 minutes",
                          "materialsNeeded": ["Motion sensors", "Data loggers", "Track and carts", "Computers", "Worksheets"],
                          "learningOutcome": "Develop hands-on experience with motion measurement and data analysis",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Setup and calibration",
                              "timeAllocation": "15 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Constant velocity measurements",
                              "timeAllocation": "25 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Constant acceleration measurements",
                              "timeAllocation": "30 minutes"
                            },
                            {
                              "stepNumber": 4,
                              "instruction": "Data analysis and discussion",
                              "timeAllocation": "20 minutes"
                            }
                          ]
                        }
                      ]
                    }
                  ]
                },
                {
                  "id": "PHY002_T2",
                  "term": "Second Term",
                  "duration": "January - March",
                  "focus": "Waves and Sound",
                  "objectives": {
                    "knowledgeObjectives": [
                      "Understand wave properties",
                      "Master sound concepts",
                      "Learn wave phenomena"
                    ],
                    "skillObjectives": [
                      "Analyze wave behavior",
                      "Calculate wave parameters",
                      "Apply wave principles"
                    ],
                    "attitudeObjectives": [
                      "Appreciate wave nature",
                      "Develop observational skills",
                      "Enhance pattern recognition"
                    ]
                  },
                  "weeks": [
                    {
                      "weekNumber": 1,
                      "topic": "Wave Properties and Characteristics",
                      "overview": "Introduction to mechanical waves: transverse and longitudinal waves, wave parameters, and wave equation.",
                      "coreCompetencies": [
                        "Identifying wave types",
                        "Calculating wave parameters",
                        "Understanding wave behavior"
                      ],
                      "scholonStandard": "Scholon Intermediate Level",
                      "notes": [
                        {
                          "id": "PHY002_T2_W1_N1",
                          "title": "Wave Basics",
                          "content": "Definition of waves, medium requirements. Transverse vs longitudinal waves. Examples from everyday life.",
                          "duration": "50 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Transverse waves", "Longitudinal waves", "Medium", "Wave propagation"],
                          "learningTags": ["waves", "basics", "types"],
                          "contentType": "theory",
                          "references": []
                        },
                        {
                          "id": "PHY002_T2_W1_N2",
                          "title": "Wave Parameters",
                          "content": "Amplitude, wavelength, frequency, period, wave speed. Relationships: v = fλ, T = 1/f. Units and measurements.",
                          "duration": "50 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Amplitude", "Wavelength", "Frequency", "Wave speed"],
                          "learningTags": ["waves", "parameters", "calculations"],
                          "contentType": "theory",
                          "references": []
                        }
                      ],
                      "quizzes": [
                        {
                          "id": "PHY002_T2_W1_Q1",
                          "title": "Wave Fundamentals Quiz",
                          "description": "Test understanding of basic wave concepts and calculations",
                          "questions": [
                            {
                              "id": "PHY002_T2_W1_Q1_Q1",
                              "question": "What type of wave is sound?",
                              "options": [
                                {"id": "A", "text": "Transverse", "isCorrect": false},
                                {"id": "B", "text": "Longitudinal", "isCorrect": true},
                                {"id": "C", "text": "Electromagnetic", "isCorrect": false},
                                {"id": "D", "text": "Standing", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "Sound waves are longitudinal because particle vibration is parallel to wave direction",
                              "scholonBloomLevel": "Remember",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["waves", "sound", "types"]
                            },
                            {
                              "id": "PHY002_T2_W1_Q1_Q2",
                              "question": "Calculate speed of wave with frequency 50 Hz and wavelength 0.4 m",
                              "options": [
                                {"id": "A", "text": "12.5 m/s", "isCorrect": false},
                                {"id": "B", "text": "20 m/s", "isCorrect": true},
                                {"id": "C", "text": "125 m/s", "isCorrect": false},
                                {"id": "D", "text": "200 m/s", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "v = fλ = 50 × 0.4 = 20 m/s",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["wave_speed", "calculations"]
                            }
                          ],
                          "duration": 25,
                          "passingScore": 70,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "formative"
                        }
                      ],
                      "assignments": [
                        {
                          "id": "PHY002_T2_W1_A1",
                          "title": "Wave Simulation Project",
                          "type": "simulation",
                          "description": "Create computer simulation of wave behavior using programming or simulation software. Demonstrate wave properties and interactions.",
                          "requirements": [
                            "Wave generation and visualization",
                            "Parameter controls (frequency, amplitude)",
                            "Demonstration of wave phenomena",
                            "Written analysis",
                            "User interface"
                          ],
                          "submissionFormat": "Software/Code with documentation",
                          "deadline": "2 weeks",
                          "totalPoints": 85,
                          "submissionCriteria": [
                            {
                              "criterion": "Functionality",
                              "maxPoints": 30,
                              "description": "Working simulation with correct physics"
                            },
                            {
                              "criterion": "Educational Value",
                              "maxPoints": 25,
                              "description": "Effectiveness in demonstrating wave concepts"
                            },
                            {
                              "criterion": "Documentation",
                              "maxPoints": 20,
                              "description": "Clear documentation and explanations"
                            },
                            {
                              "criterion": "Creativity",
                              "maxPoints": 10,
                              "description": "Innovative features or presentation"
                            }
                          ],
                          "difficulty": "Intermediate",
                          "skillsDeveloped": ["wave physics", "simulation", "programming", "visualization"]
                        }
                      ],
                      "exams": {
                        "id": "PHY002_T2_W1_EXAM",
                        "papers": [],
                        "metadata": {
                          "totalPapers": 0,
                          "totalQuestions": 0,
                          "totalMarks": 0,
                          "examFormat": "No exam this week",
                          "gradingPolicy": "N/A"
                        }
                      },
                      "activities": [
                        {
                          "id": "PHY002_T2_W1_ACT1",
                          "title": "Wave Demonstration Lab",
                          "type": "lab",
                          "description": "Hands-on demonstrations of wave properties using slinkys, ropes, and ripple tanks. Observe and measure wave behavior.",
                          "duration": "90 minutes",
                          "materialsNeeded": ["Slinkys", "Ropes", "Ripple tank", "Stroboscope", "Measuring tools"],
                          "learningOutcome": "Develop observational skills and intuitive understanding of wave behavior",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Transverse wave demonstrations with rope",
                              "timeAllocation": "25 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Longitudinal wave demonstrations with slinky",
                              "timeAllocation": "25 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Water wave observations with ripple tank",
                              "timeAllocation": "30 minutes"
                            },
                            {
                              "stepNumber": 4,
                              "instruction": "Measurement and data recording",
                              "timeAllocation": "10 minutes"
                            }
                          ]
                        }
                      ]
                    }
                  ]
                },
                {
                  "id": "PHY002_T3",
                  "term": "Third Term",
                  "duration": "April - July",
                  "focus": "Basic Electricity and Magnetism",
                  "objectives": {
                    "knowledgeObjectives": [
                      "Understand electric circuits",
                      "Learn magnetic principles",
                      "Master Ohm's law"
                    ],
                    "skillObjectives": [
                      "Analyze simple circuits",
                      "Calculate electrical quantities",
                      "Apply circuit laws"
                    ],
                    "attitudeObjectives": [
                      "Appreciate electrical safety",
                      "Develop troubleshooting skills",
                      "Enhance practical application"
                    ]
                  },
                  "weeks": [
                    {
                      "weekNumber": 1,
                      "topic": "Electric Circuits and Ohm's Law",
                      "overview": "Introduction to electric circuits, current, voltage, resistance, and Ohm's law. Series and parallel circuits.",
                      "coreCompetencies": [
                        "Applying Ohm's law",
                        "Analyzing simple circuits",
                        "Calculating circuit values"
                      ],
                      "scholonStandard": "Scholon Intermediate Level",
                      "notes": [
                        {
                          "id": "PHY002_T3_W1_N1",
                          "title": "Circuit Fundamentals",
                          "content": "Electric current, voltage, resistance definitions and units. Circuit symbols and diagrams. Basic circuit components.",
                          "duration": "50 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Current", "Voltage", "Resistance", "Circuit symbols"],
                          "learningTags": ["circuits", "electricity", "basics"],
                          "contentType": "theory",
                          "references": []
                        },
                        {
                          "id": "PHY002_T3_W1_N2",
                          "title": "Ohm's Law and Power",
                          "content": "Ohm's law: V = IR. Electrical power: P = IV = I²R = V²/R. Applications to circuit calculations.",
                          "duration": "50 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Ohm's law", "Electrical power", "Circuit calculations"],
                          "learningTags": ["ohms_law", "power", "calculations"],
                          "contentType": "theory",
                          "references": []
                        }
                      ],
                      "quizzes": [
                        {
                          "id": "PHY002_T3_W1_Q1",
                          "title": "Electric Circuits Quiz",
                          "description": "Test understanding of basic circuit concepts and Ohm's law",
                          "questions": [
                            {
                              "id": "PHY002_T3_W1_Q1_Q1",
                              "question": "Calculate current through 10Ω resistor with 20V across it",
                              "options": [
                                {"id": "A", "text": "0.5 A", "isCorrect": false},
                                {"id": "B", "text": "2 A", "isCorrect": true},
                                {"id": "C", "text": "10 A", "isCorrect": false},
                                {"id": "D", "text": "200 A", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "I = V/R = 20/10 = 2 A",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["ohms_law", "current", "calculation"]
                            },
                            {
                              "id": "PHY002_T3_W1_Q1_Q2",
                              "question": "What is power dissipated by 5Ω resistor with 2A current?",
                              "options": [
                                {"id": "A", "text": "10 W", "isCorrect": false},
                                {"id": "B", "text": "20 W", "isCorrect": true},
                                {"id": "C", "text": "25 W", "isCorrect": false},
                                {"id": "D", "text": "50 W", "isCorrect": false}
                              ],
                              "correctAnswer": 1,
                              "explanation": "P = I²R = (2)² × 5 = 4 × 5 = 20 W",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["power", "calculation", "circuits"]
                            }
                          ],
                          "duration": 25,
                          "passingScore": 70,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "formative"
                        }
                      ],
                      "assignments": [
                        {
                          "id": "PHY002_T3_W1_A1",
                          "title": "Circuit Design and Analysis Project",
                          "type": "project",
                          "description": "Design and analyze simple electric circuits for specific applications. Calculate values, predict behavior, and verify with measurements.",
                          "requirements": [
                            "Circuit design specifications",
                            "Theoretical calculations",
                            "Circuit construction (optional)",
                            "Measurement verification",
                            "Written analysis"
                          ],
                          "submissionFormat": "Design report with calculations and diagrams",
                          "deadline": "2 weeks",
                          "totalPoints": 80,
                          "submissionCriteria": [
                            {
                              "criterion": "Design Quality",
                              "maxPoints": 25,
                              "description": "Appropriateness and creativity of circuit design"
                            },
                            {
                              "criterion": "Theoretical Analysis",
                              "maxPoints": 30,
                              "description": "Accuracy and completeness of calculations"
                            },
                            {
                              "criterion": "Practical Application",
                              "maxPoints": 15,
                              "description": "Practical considerations and real-world relevance"
                            },
                            {
                              "criterion": "Documentation",
                              "maxPoints": 10,
                              "description": "Clarity of diagrams and explanations"
                            }
                          ],
                          "difficulty": "Intermediate",
                          "skillsDeveloped": ["circuit design", "electrical calculations", "practical physics", "problem solving"]
                        }
                      ],
                      "exams": {
                        "id": "PHY002_T3_W1_EXAM",
                        "papers": [],
                        "metadata": {
                          "totalPapers": 0,
                          "totalQuestions": 0,
                          "totalMarks": 0,
                          "examFormat": "No exam this week",
                          "gradingPolicy": "N/A"
                        }
                      },
                      "activities": [
                        {
                          "id": "PHY002_T3_W1_ACT1",
                          "title": "Circuit Building Workshop",
                          "type": "workshop",
                          "description": "Hands-on construction and measurement of simple electric circuits. Learn proper use of multimeters and circuit components.",
                          "duration": "90 minutes",
                          "materialsNeeded": ["Breadboards", "Resistors", "Wires", "Batteries", "Multimeters", "LEDs"],
                          "learningOutcome": "Develop practical circuit-building skills and measurement techniques",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Safety briefing and equipment introduction",
                              "timeAllocation": "15 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Simple series circuit construction",
                              "timeAllocation": "25 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Parallel circuit construction",
                              "timeAllocation": "25 minutes"
                            },
                            {
                              "stepNumber": 4,
                              "instruction": "Measurement and troubleshooting",
                              "timeAllocation": "25 minutes"
                            }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "id": "CHE002",
              "courseCode": "CHE",
              "name": "Intermediate Chemistry",
              "description": "Fundamental chemistry concepts including atomic structure, chemical bonding, and basic reactions",
              "strand": "STEM",
              "credits": 1.0,
              "scholonLevel": "Scholon Intermediate Level",
              "metadata": {
                "difficulty": "Intermediate",
                "prerequisites": ["SS1 Chemistry"],
                "targetAudience": "SS2 Students pursuing sciences or medicine",
                "version": "2.0",
                "lastUpdated": "2023-08-15T00:00:00.000",
                "instructor": "Dr. Elena Rodriguez",
                "department": "Chemistry"
              },
              "terms": [
                {
                  "id": "CHE002_T1",
                  "term": "First Term",
                  "duration": "September - December",
                  "focus": "Atomic Structure and Periodic Table",
                  "objectives": {
                    "knowledgeObjectives": [
                      "Understand atomic structure",
                      "Master periodic trends",
                      "Learn electron configuration"
                    ],
                    "skillObjectives": [
                      "Write electron configurations",
                      "Predict periodic properties",
                      "Analyze atomic spectra"
                    ],
                    "attitudeObjectives": [
                      "Appreciate atomic theory",
                      "Develop systematic thinking",
                      "Enhance pattern recognition"
                    ]
                  },
                  "weeks": [
                    {
                      "weekNumber": 1,
                      "topic": "Atomic Structure Fundamentals",
                      "overview": "Historical development of atomic theory, subatomic particles, atomic models, and basic quantum concepts.",
                      "coreCompetencies": [
                        "Understanding atomic models",
                        "Identifying subatomic particles",
                        "Applying quantum numbers"
                      ],
                      "scholonStandard": "Scholon Intermediate Level",
                      "notes": [
                        {
                          "id": "CHE002_T1_W1_N1",
                          "title": "Evolution of Atomic Theory",
                          "content": "Historical models: Dalton, Thomson, Rutherford, Bohr, quantum mechanical model. Key experiments and evidence.",
                          "duration": "50 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Atomic models", "Historical development", "Experimental evidence"],
                          "learningTags": ["atomic_structure", "history", "models"],
                          "contentType": "theory",
                          "references": []
                        },
                        {
                          "id": "CHE002_T1_W1_N2",
                          "title": "Subatomic Particles and Properties",
                          "content": "Protons, neutrons, electrons: mass, charge, location. Isotopes, mass number, atomic number. Nuclear symbols.",
                          "duration": "50 min",
                          "difficulty": "Intermediate",
                          "keyConcepts": ["Protons", "Neutrons", "Electrons", "Isotopes"],
                          "learningTags": ["subatomic", "particles", "isotopes"],
                          "contentType": "theory",
                          "references": []
                        }
                      ],
                      "quizzes": [
                        {
                          "id": "CHE002_T1_W1_Q1",
                          "title": "Atomic Structure Quiz",
                          "description": "Test understanding of atomic structure concepts and history",
                          "questions": [
                            {
                              "id": "CHE002_T1_W1_Q1_Q1",
                              "question": "Which scientist proposed nuclear atom model?",
                              "options": [
                                {"id": "A", "text": "Dalton", "isCorrect": false},
                                {"id": "B", "text": "Thomson", "isCorrect": false},
                                {"id": "C", "text": "Rutherford", "isCorrect": true},
                                {"id": "D", "text": "Bohr", "isCorrect": false}
                              ],
                              "correctAnswer": 2,
                              "explanation": "Rutherford's gold foil experiment led to nuclear atom model",
                              "scholonBloomLevel": "Remember",
                              "points": 2,
                              "questionType": "multiple_choice",
                              "tags": ["atomic_models", "history", "rutherford"]
                            },
                            {
                              "id": "CHE002_T1_W1_Q1_Q2",
                              "question": "How many protons, neutrons, electrons in ²³Na⁺?",
                              "options": [
                                {"id": "A", "text": "11p, 12n, 10e", "isCorrect": true},
                                {"id": "B", "text": "11p, 12n, 11e", "isCorrect": false},
                                {"id": "C", "text": "11p, 11n, 10e", "isCorrect": false},
                                {"id": "D", "text": "12p, 11n, 10e", "isCorrect": false}
                              ],
                              "correctAnswer": 0,
                              "explanation": "Atomic number 11 → 11 protons. Mass 23 → 12 neutrons. Na⁺ lost 1 electron → 10 electrons",
                              "scholonBloomLevel": "Apply",
                              "points": 3,
                              "questionType": "multiple_choice",
                              "tags": ["isotopes", "ions", "calculations"]
                            }
                          ],
                          "duration": 25,
                          "passingScore": 70,
                          "maxAttempts": 3,
                          "isTimed": true,
                          "quizType": "formative"
                        }
                      ],
                      "assignments": [
                        {
                          "id": "CHE002_T1_W1_A1",
                          "title": "Atomic Theory Timeline Project",
                          "type": "project",
                          "description": "Create detailed timeline of atomic theory development. Include key scientists, experiments, models, and evidence.",
                          "requirements": [
                            "Cover major historical developments",
                            "Include key experiments and evidence",
                            "Explain model limitations and advances",
                            "Visual representations",
                            "Written explanations"
                          ],
                          "submissionFormat": "Digital timeline or poster",
                          "deadline": "2 weeks",
                          "totalPoints": 80,
                          "submissionCriteria": [
                            {
                              "criterion": "Historical Accuracy",
                              "maxPoints": 25,
                              "description": "Correct historical information and chronology"
                            },
                            {
                              "criterion": "Scientific Content",
                              "maxPoints": 25,
                              "description": "Depth and accuracy of scientific explanations"
                            },
                            {
                              "criterion": "Visual Design",
                              "maxPoints": 20,
                              "description": "Clarity and effectiveness of visual presentation"
                            },
                            {
                              "criterion": "Creativity",
                              "maxPoints": 10,
                              "description": "Creative approach and presentation"
                            }
                          ],
                          "difficulty": "Intermediate",
                          "skillsDeveloped": ["scientific history", "research", "visual communication", "chronological thinking"]
                        }
                      ],
                      "exams": {
                        "id": "CHE002_T1_W1_EXAM",
                        "papers": [],
                        "metadata": {
                          "totalPapers": 0,
                          "totalQuestions": 0,
                          "totalMarks": 0,
                          "examFormat": "No exam this week",
                          "gradingPolicy": "N/A"
                        }
                      },
                      "activities": [
                        {
                          "id": "CHE002_T1_W1_ACT1",
                          "title": "Atomic Model Building Activity",
                          "type": "hands_on",
                          "description": "Build physical models representing different atomic theories. Compare and contrast model features and limitations.",
                          "duration": "90 minutes",
                          "materialsNeeded": ["Modeling materials", "Art supplies", "Reference materials", "Worksheets"],
                          "learningOutcome": "Develop concrete understanding of abstract atomic concepts through modeling",
                          "steps": [
                            {
                              "stepNumber": 1,
                              "instruction": "Review atomic models",
                              "timeAllocation": "15 minutes"
                            },
                            {
                              "stepNumber": 2,
                              "instruction": "Build Dalton's billiard ball model",
                              "timeAllocation": "20 minutes"
                            },
                            {
                              "stepNumber": 3,
                              "instruction": "Build Thomson's plum pudding model",
                              "timeAllocation": "25 minutes"
                            },
                            {
                              "stepNumber": 4,
                              "instruction": "Build Rutherford's nuclear model",
                              "timeAllocation": "20 minutes"
                            },
                            {
                              "stepNumber": 5,
                              "instruction": "Compare and discuss models",
                              "timeAllocation": "10 minutes"
                            }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ],
          "assessmentStructure": {
            "continuousAssessment": 40,
            "termlyExaminations": 60,
            "gradingScale": {
              "A+": "95-100%",
              "A": "90-94%",
              "A-": "85-89%",
              "B+": "80-84%",
              "B": "75-79%",
              "B-": "70-74%",
              "C+": "65-69%",
              "C": "60-64%",
              "D": "50-59%",
              "F": "Below 50%"
            },
            "weightDistribution": {
              "quizzes": 15,
              "assignments": 25,
              "midterm": 20,
              "final": 40
            }
          },
          "learningOutcomes": {
            "cognitiveSkills": [
              "Intermediate problem-solving and analytical thinking",
              "Basic research and investigation skills",
              "Mathematical reasoning and quantitative analysis",
              "Scientific inquiry and experimental understanding",
              "Integration of cross-disciplinary concepts"
            ],
            "practicalSkills": [
              "Laboratory techniques and safety procedures",
              "Data collection and basic analysis",
              "Use of scientific equipment and tools",
              "Basic scientific communication",
              "Digital literacy for learning"
            ],
            "softSkills": [
              "Collaboration and teamwork",
              "Time management and organization",
              "Critical thinking and evaluation",
              "Communication and presentation",
              "Adaptability and learning strategies"
            ],
            "scholonCompetencies": [
              "Scholon Problem Solver - ability to solve multi-step problems",
              "Scholon Investigator - basic research and inquiry skills",
              "Scholon Digital Learner - effective use of educational technology",
              "Scholon Communicator - clear written and oral expression",
              "Scholon Collaborator - effective teamwork skills"
            ]
          },
          "resources": {
            "textbooks": [
              {
                "title": "Scholon Intermediate Mathematics Textbook",
                "url": "https://scholon.com/books/intermediate-math",
                "type": "textbook",
                "description": "Comprehensive textbook covering all SS2 mathematics topics with examples and exercises",
                "accessType": "free",
                "format": "pdf"
              },
              {
                "title": "Conceptual Physics",
                "url": "https://scholon.com/books/conceptual-physics",
                "type": "textbook",
                "description": "Concept-based physics textbook emphasizing understanding over computation",
                "accessType": "subscription",
                "format": "epub"
              },
              {
                "title": "Chemistry: The Central Science",
                "url": "https://scholon.com/books/central-science",
                "type": "textbook",
                "description": "Comprehensive chemistry textbook focusing on fundamental concepts",
                "accessType": "subscription",
                "format": "pdf"
              },
              {
                "title": "Biology for SS2",
                "url": "https://scholon.com/books/biology-ss2",
                "type": "textbook",
                "description": "Biology textbook covering SS2 curriculum with illustrations and activities",
                "accessType": "free",
                "format": "epub"
              }
            ],
            "digitalResources": [
              {
                "title": "Scholon Learning Platform - Intermediate Level",
                "url": "https://learn.scholon.com/ss2",
                "type": "platform",
                "description": "Interactive learning platform with videos, simulations, and practice exercises for SS2",
                "accessType": "subscription",
                "format": "interactive"
              },
              {
                "title": "Khan Academy SS2 Courses",
                "url": "https://scholon.com/resources/khan-ss2",
                "type": "video_course",
                "description": "Curated collection of SS2 mathematics and science video tutorials",
                "accessType": "free",
                "format": "video"
              },
              {
                "title": "PhET Interactive Simulations - Intermediate",
                "url": "https://scholon.com/simulations/phet-ss2",
                "type": "simulation",
                "description": "Interactive science and mathematics simulations for SS2 level",
                "accessType": "free",
                "format": "interactive"
              },
              {
                "title": "Desmos Graphing Calculator",
                "url": "https://scholon.com/tools/desmos",
                "type": "tool",
                "description": "Advanced graphing calculator for mathematics exploration",
                "accessType": "free",
                "format": "web_app"
              },
              {
                "title": "Periodic Table Resources",
                "url": "https://scholon.com/resources/periodic-table",
                "type": "reference",
                "description": "Interactive periodic table with element information and properties",
                "accessType": "free",
                "format": "interactive"
              },
              {
                "title": "Virtual Chemistry Lab",
                "url": "https://scholon.com/labs/chemistry-virtual",
                "type": "simulation",
                "description": "Virtual chemistry laboratory for safe experimentation",
                "accessType": "free",
                "format": "interactive"
              }
            ],
            "laboratoryEquipment": [
              {
                "name": "Scholon Intermediate Physics Lab Kit",
                "description": "Basic physics equipment for mechanics, waves, and electricity experiments",
                "quantity": 20,
                "specifications": "Includes motion sensors, force meters, wave apparatus, circuit components",
                "safetyLevel": "Level 1 - Basic supervision"
              },
              {
                "name": "Chemistry Basic Lab Equipment",
                "description": "Standard chemistry lab equipment for SS2 experiments",
                "quantity": 15,
                "specifications": "Beakers, test tubes, Bunsen burners, balances, basic chemicals",
                "safetyLevel": "Level 2 - Chemical handling with supervision"
              },
              {
                "name": "Biology Microscope Sets",
                "description": "Compound microscopes for cell and tissue observation",
                "quantity": 20,
                "specifications": "40x-1000x magnification, prepared slides, staining materials",
                "safetyLevel": "Level 1 - Basic supervision"
              },
              {
                "name": "Mathematics Geometry Kits",
                "description": "Geometry tools for construction and measurement",
                "quantity": 30,
                "specifications": "Compasses, protractors, rulers, set squares, graph paper",
                "safetyLevel": "Level 1 - Basic use"
              }
            ],
            "softwareTools": [
              {
                "name": "Scholon Math Studio",
                "version": "1.5.0",
                "purpose": "Mathematics learning software with interactive exercises and graphing tools",
                "license": "Educational",
                "systemRequirements": "Windows 10+, macOS 10.13+, 4GB RAM, 2GB storage"
              },
              {
                "name": "GeoGebra Classic",
                "version": "6.0",
                "purpose": "Dynamic mathematics software for geometry, algebra, and graphing",
                "license": "Free",
                "systemRequirements": "Web-based or desktop application"
              },
              {
                "name": "Microsoft Excel/Google Sheets",
                "version": "Latest",
                "purpose": "Spreadsheet software for data analysis and mathematical calculations",
                "license": "Subscription/Free",
                "systemRequirements": "Varies by platform"
              },
              {
                "name": "ChemSketch Freeware",
                "version": "2023",
                "purpose": "Chemical structure drawing software for chemistry students",
                "license": "Free",
                "systemRequirements": "Windows 7+, 2GB RAM"
              },
              {
                "name": "Scratch Programming",
                "version": "3.0",
                "purpose": "Visual programming language for learning computational thinking",
                "license": "Free",
                "systemRequirements": "Web-based or desktop application"
              },
              {
                "name": "Audacity Audio Editor",
                "version": "3.2",
                "purpose": "Audio editing software for sound wave analysis in physics",
                "license": "Open Source",
                "systemRequirements": "Windows/macOS/Linux, 2GB RAM"
              }
            ]
          },
          "schedule": {
            "terms": [
              {
                "term": 1,
                "duration": "September - December",
                "weeks": 12,
                "startDate": "2023-09-04T00:00:00.000",
                "endDate": "2023-12-15T00:00:00.000",
                "holidays": ["Mid-term Break: October 9-13, 2023", "Thanksgiving: November 23-24, 2023"]
              },
              {
                "term": 2,
                "duration": "January - March",
                "weeks": 12,
                "startDate": "2024-01-08T00:00:00.000",
                "endDate": "2024-03-22T00:00:00.000",
                "holidays": ["Mid-term Break: February 12-16, 2024", "Presidents' Day: February 19, 2024"]
              },
              {
                "term": 3,
                "duration": "April - July",
                "weeks": 12,
                "startDate": "2024-04-08T00:00:00.000",
                "endDate": "2024-07-12T00:00:00.000",
                "holidays": ["Mid-term Break: May 27-31, 2024", "Memorial Day: May 27, 2024", "Independence Day: July 4, 2024"]
              }
            ],
            "totalWeeks": 36,
            "totalHours": 1440,
            "contactHoursPerWeek": 40,
            "startDate": "2023-09-04T00:00:00.000",
            "endDate": "2024-07-12T00:00:00.000",
            "importantDates": [
              "Orientation: September 1-3, 2023",
              "First Term Exams: December 11-15, 2023",
              "Second Term Exams: March 18-22, 2024",
              "Final Exams: July 8-12, 2024",
              "Promotion Ceremony: July 13, 2024"
            ]
          },
          "policies": {
            "attendance": "Minimum 80% attendance required for promotion",
            "academicIntegrity": "Academic honesty expected; plagiarism results in grade penalties",
            "assessment": "Regular assessment completion required; makeup exams with valid reasons",
            "technology": "Educational use of personal devices permitted",
            "safety": "Strict adherence to laboratory safety rules",
            "supportServices": [
              "Academic support sessions twice weekly",
              "Subject-specific tutoring available",
              "Study skills workshops",
              "Career exploration guidance",
              "Parent-teacher consultation evenings"
            ]
          }
        }
      ]
''';
}