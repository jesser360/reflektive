class PagesController < ApplicationController
  require 'httparty'
  include HTTParty

  @@headers = {
    "Authorization"  => "Token b73d8d97-a099-4018-b5df-fe299161907a",
    "Content-Type": "application/json",
    'Accept' => 'application/json'
  }

  def home
    @employees = HTTParty.get(
      "https://reflektive-interview.herokuapp.com/v1/employees/",
      :headers => @@headers
    )
    @feedbacks = HTTParty.get(
      "https://reflektive-interview.herokuapp.com/v1/feedbacks",
      :headers => @@headers
    )

    @employees.each do |employee|
      if employee['id'] == '46268730-2ca4-441f-8038-ec0ae6bb478b'
        puts employee['manager_id']
      end
    end

    def get_feedback_scores(manager_id)
      @employee_feedbacks = {}
      @feedbacks.each do |feedback|
        if feedback['recipient_id'] ==  manager_id
          # puts feedback
          unless @employee_feedbacks.key?(feedback['question']['id'])
            @employee_feedbacks[feedback['question']['id']] = []
          end
          @employee_feedbacks[feedback['question']['id']] << feedback['score']
        end
      end

      employee_reviews = []
      @employee_feedbacks.each do |question,scores|
         average_score_per_q = {}
         average_score = @employee_feedbacks[question].sum.fdiv(@employee_feedbacks[question].size)
         average_score_per_q[:question_id] = question
         average_score_per_q[:manager_id] = manager_id
         average_score_per_q[:average_score] = average_score
         employee_reviews.push(average_score_per_q)
      end
      return employee_reviews
    end

    @json_request = []
    @json_request = get_feedback_scores('ab487f8c-8ebc-4bf6-b8fa-8dc85f880716') + get_feedback_scores('f4cb98dc-e6a0-488e-93a2-e9241c5b70f6')
    @response = HTTParty.post("https://reflektive-interview.herokuapp.com/v1/manager_submissions",
      :body => @json_request.to_json,
      :headers => @@headers
    )
  end

end
