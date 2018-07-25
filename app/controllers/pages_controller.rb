class PagesController < ApplicationController
  require 'httparty'
  include HTTParty

  @@headers = {
    "Authorization"  => "Token b73d8d97-a099-4018-b5df-fe299161907a",
    "Content-Type": "application/json",
    'Accept' => 'application/json'
  }

  @@employees = HTTParty.get(
    "https://reflektive-interview.herokuapp.com/v1/employees/",
    :headers => @@headers
  )

  @@feedbacks = HTTParty.get(
    "https://reflektive-interview.herokuapp.com/v1/feedbacks",
    :headers => @@headers
  )

  def get_feedback_scores(manager_id)
    @employee_feedbacks = {}
    # CREATES A HASH WITH EACH KEY AS ONE QUESTION'S ID AND ITS VALUES AS AN ARRAY OF EACH FEEDBACK SCORE FOR THAT QUESTION
    @@feedbacks.each do |feedback|
      if feedback['reviewer_id'] ==  manager_id
        unless @employee_feedbacks.key?(feedback['question']['id'])
          @employee_feedbacks[feedback['question']['id']] = []
        end
        @employee_feedbacks[feedback['question']['id']] << feedback['score']
      end
    end

    employee_reviews = []
    # GO THROUGH EACH KEY VALUE PAIR TO FIND THE AVERAGE SCORE FOR EACH QUESTION
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

  def home
    @employee_list = []
    @@employees.each do |employee|
      @employee_list.push({:id =>employee['id'],:name =>employee['name']})
    end
    # CREATING JSON REQUEST TO SEND BOTH MANAGERS IDS FEEDBACK SCORES TO API
    @json_request = []
    @json_request = get_feedback_scores('ab487f8c-8ebc-4bf6-b8fa-8dc85f880716') + get_feedback_scores('f4cb98dc-e6a0-488e-93a2-e9241c5b70f6')
    @response = HTTParty.post("https://reflektive-interview.herokuapp.com/v1/manager_submissions",
      :body => @json_request.to_json,
      :headers => @@headers
    )
  end

  def search
    @employee_id = params[:employee_id]
    puts params
    @@employees.each do |employee|
      if employee['id']== @employee_id
        @employee = employee
      end
    end
    @results = get_feedback_scores(@employee_id)

  end

end
