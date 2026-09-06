class Task < ApplicationRecord
    # 確保格式正確、資料齊全的資料才能寫入資料庫
    # 不能為空的資料
    validates :title, presence: true, length: { maximum: 100 } # 字數限制
    validates :status, presence: true
end