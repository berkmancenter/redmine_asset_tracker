# @author Emmanuel Pastor
namespace :notifications do
  namespace :send do
    
    desc "Send email reminders to those who haven't checked in or out an asset due time"
    task :all_reminders => :environment do
      Reservation.send_day_reminders
    end

    desc "Send email reminders to those who haven't checked in an asset due time"
    task :check_in_reminders => :environment do
      Reservation.send_day_check_in_reminders
    end

    desc "Send email reminders to those who haven't checked out an asset due time"
    task :check_out_reminders => :environment do
      Reservation.send_day_check_out_reminders
    end

    desc "Send daily email digest reminder to Admin"
    task :all_reminders => :environment do
      Reservation.send_day_digest
    end

  end
end
