module TownHall
  class ConfigurationsController < TownHallController
    def index
      @configurations = Configuration.order(:name)
    end

    def new
      @configuration = Configuration.new
    end

    def create
      @configuration = Configuration.new(configuration_params)

      if @configuration.save
        redirect_to town_hall_configurations_path, notice: "Configuration added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @configuration = Configuration.find(params[:id])
    end

    def update
      @configuration = Configuration.find(params[:id])

      if @configuration.update(configuration_params)
        redirect_to town_hall_configurations_path, notice: "Configuration updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      Configuration.find(params[:id]).destroy
      redirect_to town_hall_configurations_path, notice: "Configuration removed."
    end

    private

    def configuration_params
      params.require(:configuration).permit(:name, :value)
    end
  end
end
