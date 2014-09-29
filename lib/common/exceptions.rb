class InterruptException < Exception; end
class UserInterruptException < InterruptException; end
class KillInterruptException < InterruptException; end

