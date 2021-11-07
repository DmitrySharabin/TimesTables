//
//  ContentView.swift
//  TimesTables
//
//  Created by Dmitry Sharabin on 07.11.2021.
//

import SwiftUI

struct Question {
    let text: String
    let answer: Int
}

struct ContentView: View {
    @State private var isGameActive = false
    
    static let multiplicationTableRange = 2...12
    @State private var multiplicationTable = Int.random(in: multiplicationTableRange)
    
    static let questionCountOptions = [5, 10, 20]
    @State private var questions = [Question]()
    @State private var questionCount = questionCountOptions.randomElement() ?? 5
    @State private var questionNumber = 1
    
    @State private var answer: Int? = nil
    @State private var correct = 0
    @State private var wrong = 0
    
    @State private var isShowingAlert = false
    @FocusState private var answerIsFocused: Bool
    
    var question: String {
        if questions.isEmpty || questionNumber > questions.count {
            return ""
        } else {
            return questions[questionNumber - 1].text
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                if isGameActive {
                    Section {
                        Text("Question \(questionNumber) of \(questionCount)")
                    }
                    
                    Section("Question") {
                        Text(question)
                        
                        TextField("Enter your answer", value: $answer, format: .number)
                            .keyboardType(.numberPad)
                            .focused($answerIsFocused)
                    }
                    
                    Section("Score") {
                        Text("Correct: \(correct)")
                        Text("Wrong: \(wrong)")
                    }
                } else {
                    Section("Let's master") {
                        Stepper("\(multiplicationTable) times table", value: $multiplicationTable, in: Self.multiplicationTableRange)
                    }
                    
                    Section {
                        Picker("Choose number of questions", selection: $questionCount) {
                            ForEach(Self.questionCountOptions, id: \.self) {
                                Text($0, format: .number)
                            }
                        }
                        .pickerStyle(.segmented)
                    } header: {
                        Text("How about")
                    } footer: {
                        Text("questions?".uppercased())
                    }
                    
                    
                    Section {
                        Button("Start Game", action: startGame)
                    }
                }
            }
            .navigationTitle("TimesTables")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Spacer()
                        
                        Button("Answer") {
                            answerIsFocused = false
                            checkAnswer()
                        }
                    }
                }
            }
            .onSubmit {
                checkAnswer()
            }
            .alert("Game Over", isPresented: $isShowingAlert) {
                Button("New Game", role: .cancel, action: newGame)
            } message: {
                Text("You gave correct answers for \(correct) \(correct == 1 ? "question" : "questions") out of \(questionCount).")
            }
        }
    }
    
    func startGame() {
        questions = []
        for i in Self.multiplicationTableRange {
            questions.append(Question(text: "\(multiplicationTable) x \(i) is", answer: multiplicationTable * i))
        }
        questions.shuffle()
        
        if questionCount > questions.count {
            var extraQuestions = [Question]()
            let extraQuestionCount = questionCount - questions.count
            
            for _ in 0..<extraQuestionCount {
                let question = questions.randomElement() ?? Question(text: "0 x 0", answer: 0)
                extraQuestions.append(question)
            }
            
            questions.append(contentsOf: extraQuestions)
        }
        
        questionNumber = 1
        
        isGameActive = true
    }
    
    func checkAnswer() {
        if questions[questionNumber - 1].answer == answer {
            correct += 1
        } else {
            wrong += 1
        }
        
        if questionNumber == questionCount {
            isShowingAlert = true
        } else {
            questionNumber += 1
            answer = nil
        }
    }
    
    func newGame() {
        multiplicationTable = Int.random(in: Self.multiplicationTableRange)
        questionCount = Self.questionCountOptions.randomElement() ?? 5
        
        answer = nil
        correct = 0
        wrong = 0
        
        isGameActive = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
