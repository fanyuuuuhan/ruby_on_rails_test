
module TasksHelper
  def task_options_for_select
    [
        [ t("tasks.sort_orders.created_at_asc"), "created_at_asc" ],
        [ t("tasks.sort_orders.created_at_desc"), "created_at_desc" ],
        [ t("tasks.sort_orders.title_asc"), "title_asc" ],
        [ t("tasks.sort_orders.due_date_asc"), "due_date_asc" ],
        [ t("tasks.sort_orders.due_date_desc"), "due_date_desc" ],
        [ t("tasks.sort_orders.priority_asc"), "priority_asc" ],
        [ t("tasks.sort_orders.priority_desc"), "priority_desc" ]
    ]
  end
end
