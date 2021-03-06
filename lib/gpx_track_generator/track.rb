# encoding: utf-8
module GpxTrackGenerator
  # Track
  class Track
    private

    attr_reader :files, :name, :reverse, :single_segment

    public

    def initialize(files, name:, reverse:, single_segment:)
      @files          = files
      @name           = name
      @reverse        = reverse
      @single_segment = single_segment
    end

    def to_s
      build_document
    end

    private

    def creator
      'gpx_track_generator'
    end

    def creator_url
      'https://github.com/maxmeyer/gpx_track_generator'
    end

    # rubocop:disable Metrics/PerceivedComplexity
    def build_document
      document.child << metadata

      document.child << document.create_element('trk')
      document.css('trk').first << document.create_element('name')
      document.css('name').first.content = name

      if single_segment
        document.css('trk').first << document.create_element('trkseg')

        files.each_with_object(document.css('trk').first) do |e, a|
          segment = a.css('trkseg').last
          segment << "<!-- #{e.file_name} -->"
          segment << (reverse ? e.nodes.reverse : e.nodes)
        end
      else
        files.each_with_object(document.css('trk').first) do |e, a|
          a << "<!-- #{e.file_name} -->"
          a << document.create_element('trkseg')

          segment = a.css('trkseg').last
          segment << (reverse ? e.nodes.reverse : e.nodes)
        end
      end

      if reverse
        document.css('trkpt').reverse.each_with_index { |e, i| e.css('name').first.content = "WP #{i + 1}" }
      else
        document.css('trkpt').each_with_index { |e, i| e.css('name').first.content = "WP #{i + 1}" }
      end

      document.dup.human
    end
    # rubocop:enable Metrics/PerceivedComplexity

    def document
      @document ||= Nokogiri::XML(
      <<-EOS.strip_heredoc
    <gpx xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" version="1.1" creator="#{creator}" xmlns="http://www.topografix.com/GPX/1/1"></gpx>
      EOS
      )
    end

    def metadata
      @metadata ||= Nokogiri::XML::DocumentFragment.parse <<-EOS.strip_heredoc
      <metadata>
        <desc>GPX file generated by #{creator}</desc>
        <link href="#{creator_url}">
          <text>#{creator}</text>
        </link>
        <time>#{Time.now}</time>
      </metadata>
      EOS
    end
  end
end
