module TownHall
  class ProfileQuestionsController < TownHallController
    def index
      @profile_questions = ProfileQuestion.order(:position)
    end

    def new
      @profile_question = ProfileQuestion.new
    end

    def create
      @profile_question = ProfileQuestion.new(profile_question_params)

      if @profile_question.save
        redirect_to town_hall_profile_questions_path, notice: "Question added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @profile_question = ProfileQuestion.find(params[:id])
    end

    def update
      @profile_question = ProfileQuestion.find(params[:id])

      if @profile_question.update(profile_question_params)
        redirect_to town_hall_profile_questions_path, notice: "Question updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def profile_question_params
      params.require(:profile_question).permit(:question, :llm_prompt, :active, :position)
    end
  end
end
