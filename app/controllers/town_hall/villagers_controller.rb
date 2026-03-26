module TownHall
  class VillagersController < TownHallController
    def index
      @villagers = Villager.order(:last_name, :first_name)
    end

    def new
      @villager = Villager.new
    end

    def create
      @villager = Villager.new(villager_params)

      if @villager.save(context: :interactive)
        redirect_to town_hall_villagers_path, notice: "Villager added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @villager = Villager.find(params[:id])
    end

    def update
      @villager = Villager.find(params[:id])

      @villager.assign_attributes(villager_params)
      if @villager.save(context: :interactive)
        redirect_to town_hall_villagers_path, notice: "Villager updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      Villager.find(params[:id]).destroy
      redirect_to town_hall_villagers_path, notice: "Villager removed."
    end

    def sync
      villagers = Villager.all.to_a
      slugs = villagers.each_with_object({}) { |v, h| h[v.tito_ticket_slug] = v if v.tito_ticket_slug.present? }
      emails = villagers.each_with_object({}) { |v, h| (h[v.email.downcase] ||= v) if v.email.present? && v.tito_ticket_slug.blank? }

      already = 0
      connected = 0
      added = 0

      Villager.tito_client.tickets.each do |ticket|
        if slugs[ticket.slug]
          already += 1
        elsif (villager = emails[ticket.email.to_s.downcase])
          villager.update!(tito_ticket_slug: ticket.slug, first_name: ticket.first_name, last_name: ticket.last_name)
          connected += 1
        else
          Villager.create!(tito_ticket_slug: ticket.slug, first_name: ticket.first_name, last_name: ticket.last_name, email: ticket.email)
          added += 1
        end
      end

      redirect_to town_hall_villagers_path, notice: "Sync complete: #{already} already linked, #{connected} connected, #{added} added."
    end

    private

    def villager_params
      params.require(:villager).permit(:first_name, :last_name, :email)
    end
  end
end
