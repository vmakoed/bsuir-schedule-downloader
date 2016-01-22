require 'nokogiri'
require 'open-uri'
require 'fileutils'

class SchedulesDownloader
  GROUPS_INFO_URL = 'http://www.bsuir.by/schedule/rest/studentGroup'
  GROUP_SCHEDULE_URL_START = 'http://www.bsuir.by/schedule/rest/schedule'

  def initialize(download_location)
    @download_location = download_location
    ensure_directory_existence(@download_location)
  end

  def load_group_schedule(group_number)
    schedule_url = form_schedule_url_by_id(retrieve_group_id(group_number))
    xml_file_path = form_xml_file_path(group_number)
    download(schedule_url, xml_file_path)
  end

  def load_all_schedules
    get_groups_info_from_xml.each do |group_info|
      download_by_group_info(group_info)
    end
  end

  private

  def ensure_directory_existence(directory)
    FileUtils.mkdir_p(directory) unless File.directory?(directory)
  end

  def download(source, destination)
    IO.copy_stream(open(source), destination)
  end

  def download_by_group_info(group_info_from_xml)
    schedule_url = form_schedule_url_by_id(find_group_id(group_info_from_xml))
    xml_file_path = form_xml_file_path(find_group_number(group_info_from_xml))
    download(schedule_url, xml_file_path)
  end

  def retrieve_group_id(group_number)
    group_id = ''
    get_groups_info_from_xml.each do |group_info|
      if group_info.css('name').text == group_number
        group_id = group_info.css('id').text
        break
      end
    end
    group_id
  end

  def get_groups_info_from_xml
    Nokogiri::XML(open(GROUPS_INFO_URL)).css('studentGroup')
  end

  def find_group_number(group_info_from_xml)
    group_info_from_xml.css('name').text
  end

  def find_group_id(group_info_from_xml)
    group_info_from_xml.css('id').text
  end

  def form_schedule_url_by_id(group_id)
    "#{GROUP_SCHEDULE_URL_START}/#{group_id}"
  end

  def form_xml_file_path(group_number)
    File.join(@download_location, "/#{group_number}.xml")
  end
end