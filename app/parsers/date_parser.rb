class DateParser
  def self.parse(date_string)

    date_string = date_string.strip

    # Catches if user inputs just year which Chronic would parse as a time. e.g. "2008" as "8:08pm"
    if date_string.match(/^\d{4}$/)
      date_string = "01/01/#{date_string}"
    end

    # Catches fully padded dates without delimiters, eg 01012001
    if date_string.match(/^\d{8}$/)
      date_string = date_string.gsub(/(\d{2})(\d{2})(\d{4})/, '\1/\2/\3')
    end

    # Converts spaces or dots with slashes, eg 01.01.2001 to 01/01/2001
    date_string = date_string.gsub(/(\d+)[. ](\d+)[. ]/, '\1/\2/')

    if date = Chronic.parse(date_string, guess: :begin, :endian_precedence => :little)
      date.to_date
    else
      nil
    end
  end
end