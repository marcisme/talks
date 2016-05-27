require "minitest/autorun"
require "minitest/pride"
require "timeout"

class TestTimeout < Minitest::Test

  def test_happy_path
    completed = false
    Timeout.timeout(0.001) do
      completed = true
    end
    assert completed
  end

  def test_rescue
    completed = false
    begin
      Timeout.timeout(0.001) do
        begin
          raise
        rescue
          sleep 0.002
          completed = true
        end
      end
    rescue
    end
    refute completed, "rescue block did not complete"
  end

  def test_ensure
    completed = false
    begin
      Timeout.timeout(0.001) do
        begin
        ensure
          sleep 0.002
          completed = true
        end
      end
    rescue
    end
    refute completed, "ensure block did not complete"
  end

  def test_ensure_with_handle_interrupt_never
    completed = false
    begin
      Timeout.timeout(0.001) do
        Thread.handle_interrupt(Timeout::Error => :never) do
          begin
          ensure
            sleep 0.002
            completed = true
          end
        end
      end
    rescue
    end
    assert completed, "ensure block did not complete"
  end

  def test_ensure_with_handle_interrupt_never_and_immediate
    never_ran, completed = true, false
    begin
      Timeout.timeout(0.001) do
        Thread.handle_interrupt(Timeout::Error => :never) do
          begin
            Thread.handle_interrupt(Timeout::Error => :immediate) do
              sleep 0.002
              never_ran = false
            end
          ensure
            completed = true
          end
        end
      end
    rescue
    end
    assert never_ran, "main block executed unexpectedly"
    assert completed, "ensure block did not complete"
  end

end
