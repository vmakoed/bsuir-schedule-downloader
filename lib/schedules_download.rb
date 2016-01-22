require 'schedules_download/schedules_downloader'

module SchedulesDownload
  def SchedulesDownload.download_group_schedule(group_number, download_location)
    SchedulesDownloader.new(download_location).load_group_schedule(group_number)
  end

  def SchedulesDownload.download_all_schedules(download_location)
    SchedulesDownloader.new(download_location).load_all_schedules
  end
end