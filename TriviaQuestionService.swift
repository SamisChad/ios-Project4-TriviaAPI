//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Sam on 06/07/25.
//

import Foundation

class TriviaQuestionService {
    func fetchTriviaQuestions(completion: @escaping ([TriviaQuestion]) -> Void) {
        let urlString = "https://opentdb.com/api.php?amount=10"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(TriviaAPIResponse.self, from: data)
                let questions = result.results.map { dto in
                    TriviaQuestion(
                        category: dto.category.htmlDecoded,
                        question: dto.question.htmlDecoded,
                        correctAnswer: dto.correct_answer.htmlDecoded,
                        incorrectAnswers: dto.incorrect_answers.map { $0.htmlDecoded }
                    )
                }
                completion(questions)
            } catch {
                print("Error decoding JSON: \(error)")
                completion([])
            }
        }.resume()
    }
}

// MARK: - DTOs

struct TriviaAPIResponse: Codable {
    let response_code: Int
    let results: [TriviaQuestionDTO]
}

struct TriviaQuestionDTO: Codable {
    let category: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

import Foundation

extension String {
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        return (try? NSAttributedString(data: data, options: options, documentAttributes: nil).string) ?? self
    }
}
