# http://hawkins.io/2013/08/using-the-ruby-logger/
# class CustomFormater < Logger::Formater
#   def call(severity, time, progname, msg)
#    # msg2str is the internal helper that handles different msgs correctly
#     "#{time} - #{msg2str(msg)}"
#   end
# end

module Alfred

  class Internal

    def initialize(data, cache)
      @@data   = data
      @@cache  = cache
      @@bundle = 'foo.my.poop'
      @@major_version = 'ruby-dev'
      @@wf_data = File.join( File.expand_path('~/'), 'Library',
        'Application Support', 'Alfred 2', 'Workflow Data', @@bundle)

      self.initialize_logs()
    end


    def method_missing(name, *arguments)
      self.console("'#{name}' does not exist either externally or internally.")
    end

    def icon(args)
      puts args['font']
    end



    def initialize_modern
      # For Alfred >= v2.4:277
    end

    def initialize_deprecated
      # For Alfred < v2.4:277
    end

    # @TODO combine the log and file commands

    def initialize_logs
      self.initialize_bundler_log()
      self.initialize_user_log()
    end

    def initialize_user_log

      FileUtils.mkdir(@@wf_data) unless File.directory?(@@wf_data)

      @@user    = Logger.new(File.join(@@wf_data, @@bundle + '.log'), 1, 1024000)
      # Redo formatting to make everythng nice
      @@user.formatter = proc do |severity, datetime, progname, msg|
        trace = caller.last.split(':')
        file = Pathname.new(trace[0]).basename
        line = trace[1]
        date = Time.now.strftime("%Y-%m-%d %H:%M:%S")

        if severity == 'FATAL'
          severity = 'CRITICAL'
        elsif severity == 'WARN'
          severity = 'WARNING'
        end

        "[#{date}] [#{file}:#{line}] [#{severity}] #{msg}\n"
      end
    end

    def initialize_bundler_log
      @@console = Logger.new(STDERR)

      # Redo formatting to make everythng nice
      @@console.formatter = proc do |severity, datetime, progname, msg|
        trace = caller.last.split(':')
        file = Pathname.new(trace[0]).basename
        line = trace[1]
        date = Time.now.strftime("%H:%M:%S")

        if severity == 'FATAL'
          severity = 'CRITICAL'
        elsif severity == 'WARN'
          severity = 'WARNING'
        end

        "[#{date}] [#{file}:#{line}] [#{severity}] #{msg}\n"
      end

      @@file    = Logger.new(File.join(@@data, 'data', 'logs', 'bundler-' + @@major_version + '.log'), 1, 1024000)
      # Redo formatting to make everythng nice
      @@file.formatter = proc do |severity, datetime, progname, msg|
        trace = caller.last.split(':')
        file = Pathname.new(trace[0]).basename
        line = trace[1]
        date = Time.now.strftime("%Y-%m-%d %H:%M:%S")

        if severity == 'FATAL'
          severity = 'CRITICAL'
        elsif severity == 'WARN'
          severity = 'WARNING'
        end


        "[#{date}] [#{file}:#{line}] [#{severity}] #{msg}\n"
      end
    end

    def log(msg, level = 'info' )
      # Lowercase the level name
      level.downcase!

      # define the levels and their
      levels = {
        'debug' => 'debug',
        'info'  => 'info',
        'warning' => 'warn',
        'warn' => 'warn',
        'error' => 'error',
        'fatal' => 'fatal',
        'critical' => 'fatal'
      }
      unless levels.has_key?(level)
        self.console("#{level} is not a valid level, falling back to 'info'", 'debug')
        level = 'info'
      end
      level = levels[level]
      @@file.send(level, msg)
    end

    def console(msg, level='info')
      # Lowercase the level name
      level.downcase!

      # define the levels and their
      levels = {
        'debug' => 'debug',
        'info'  => 'info',
        'warning' => 'warn',
        'warn' => 'warn',
        'error' => 'error',
        'fatal' => 'fatal',
        'critical' => 'fatal'
      }
      unless levels.has_key?(level)
        self.console("#{level} is not a valid level, falling back to 'info'", 'debug')
        level = 'info'
      end
      level = levels[level]
      @@console.send(level, msg)
    end

  end

end