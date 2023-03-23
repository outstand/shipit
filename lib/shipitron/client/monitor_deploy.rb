require 'shipitron'
require 'shipitron/client'
require 'shipitron/ecs_client'
require 'tty-table'
require 'tty-cursor'
require 'tty-command'
require 'pastel'

module Shipitron
  module Client
    class MonitorDeploy
      include Metaractor
      include EcsClient

      required :region
      required :cluster
      required :task_arn

      def call
        Logger.info "Monitoring deploy:"
        puts

        cursor = TTY::Cursor

        rows = 0
        catch(:done) do
          loop do
            response =
              ecs_client(region: context.region)
              .describe_tasks(
                cluster: context.cluster,
                tasks: [
                  context.task_arn
                ]
              )

            task = response.tasks.first

            print cursor.clear_lines(rows, :up) if rows > 0
            rows = 0

            puts "Task status: #{color_status(status: task.last_status)}"
            rows += 1

            shipitron_status = "provisioning"
            table = TTY::Table.new(
              header: [blue.("Container name"), blue.("Status"), blue.("Health status")]
            ) do |t|
              task.containers.each do |container|
                if container.name == "shipitron"
                  shipitron_status = container.last_status
                  unless %w[provisioning pending activating].include?(container.last_status.downcase)
                    throw(:done)
                  end
                end

                status = color_status(
                  status: container.last_status,
                  exit_code: container.exit_code
                )

                health_status = color_health_status(
                  health_status: container.health_status
                )

                t << [container.name, status, health_status]
              end
            end
            puts table.render(
              :unicode,
              padding: [0, 1]
            )

            rows += table.rows_size + 5

            $stdout.flush

            # Break out if shipitron has started
            unless %w[provisioning pending activating].include?(shipitron_status.downcase)
              throw(:done)
            end

            # Break out if task is past running
            unless %w[provisioning pending activating running].include?(task.last_status.downcase)
              throw(:done)
            end

            sleep 5
          end
        end

        show_logs
      end

      private

      def show_logs
        Logger.info "Run: cw tail /aws/ecs/#{context.cluster}:shipitron/shipitron -f"
      end

      def color_status(status:, exit_code: nil)
        case status.downcase
        when "running"
          pastel.green("Running")
        when "stopped"
          if exit_code.nil?
            "Stopped"
          else
            "Stopped | Exit code: #{exit_code}"
          end
        else
          status.capitalize
        end
      end

      def color_health_status(health_status:)
        case health_status.downcase
        when "healthy"
          pastel.green("Healthy")
        when "unhealthy"
          pastel.red("Unhealthy")
        when "unknown"
          pastel.blue("Unknown")
        end
      end

      def blue
        pastel.blue.detach
      end

      def pastel
        return @pastel if defined?(@pastel)

        @pastel =
          Pastel.new
      end
    end
  end
end
