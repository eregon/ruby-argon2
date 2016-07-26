# frozen_string_literal: true
require 'argon2/constants'
begin
  require 'argon2/ffi_engine'
rescue LoadError
  require 'argon2/cext_engine'
end
require 'argon2/version'
require 'argon2/errors'
require 'argon2/engine.rb'

module Argon2
  # Front-end API for the Argon2 module.
  class Password
    def initialize(options = {})
      @t_cost = options[:t_cost] || 2
      raise ArgonHashFail, "Invalid t_cost" if @t_cost < 1 || @t_cost > 10
      @m_cost = options[:m_cost] || 16
      raise ArgonHashFail, "Invalid m_cost" if @m_cost < 1 || @m_cost > 31
      @salt = options[:salt_do_not_supply] || Engine.saltgen
      @secret = options[:secret]
    end

    def create(pass)
      Argon2::Engine.hash_argon2i_encode(
              pass, @salt, @t_cost, @m_cost, @secret)
    end

    # Helper class, just creates defaults and calls hash()
    def self.create(pass)
      argon2 = Argon2::Password.new
      argon2.create(pass)
    end

    def self.verify_password(pass, hash, secret = nil)
      raise ArgonHashFail, "Invalid hash" unless
        /^\$argon2i\$.{,112}/ =~ hash

      hash.gsub! "argon2$", "argon2$v=19$" unless
        /^\$argon2i\$v=/ =~ hash

      Argon2::Engine.argon2i_verify(pass, hash, secret)
    end
  end
end
