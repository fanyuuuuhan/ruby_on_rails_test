
module TasksHelper
  def task_options_for_select
    [
        [t("依建立時間排序(由舊到新)"), "created_at_asc"],
        [t("依建立時間排序(由新到舊)"), "created_at_desc"],
        [t("依標題排序(由小到大)"), "title_asc"],
        [t("依截止日期排序(由近到遠)"), "due_date_asc"],
        [t("依截止日期排序(由遠到近)"), "due_date_desc"],
        [t("依優先順序排序(由低到高)"), "priority_asc"],
        [t("依優先順序排序(由高到低)"), "priority_desc"]

    ]
    