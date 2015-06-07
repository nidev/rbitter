# encoding: utf-8

module Rbitter
  module Progress
    @@last_draw = 0
    def putback
      $> << "\r"
    end

    def draw sentence
      $> << sentence
      if sentence.length < @@last_draw
        $> << " "*(@@last_draw - sentence.length)
      end
      @@last_draw = sentence.length
      putback
    end

    def newline
      puts ""
    end
  end
end
