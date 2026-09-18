require 'bcrypt'

class User < ApplicationRecord
    has_many :tasks, dependent: :destroy
    before_destroy :prevent_destroying_last_admin

    validate :prevent_removing_last_admin_role, on: :update

    attr_reader :password
    attr_accessor :password_confirmation
    
    validates :email, presence: true, uniqueness: true
    validates :password,
        presence: true,
        length: { minimum: 6 },
        if: :password_required?
    validates :password, confirmation: true

    def password=(plain_password)
        @password = plain_password
        if plain_password.present?
            self.password_digest = BCrypt::Password.create(plain_password).to_s
        end
    end

    def authenticate(plain_password)
        return false if password_digest.blank?
        BCrypt::Password.new(self.password_digest) == plain_password
    end

    private
    def password_required?
        new_record? || password.present?
    end

    def prevent_destroying_last_admin
        return unless admin?
        if User.where(admin: true).count <= 1
            errors.add(:base, I18n.t("users.model.cannot_delete_last_admin"))
            throw(:abort)
        end
    end

    def prevent_removing_last_admin_role
        if admin_was && !admin && User.where(admin: true).count <= 1
            errors.add(:admin, I18n.t("users.model.cannot_remove_last_admin"))
            throw(:abort)
        end
    end
end
