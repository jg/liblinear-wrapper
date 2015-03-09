class Shell
  def run(command)
    puts "#{command}"
    system(command)
  end
end
