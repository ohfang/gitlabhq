class IssueObserver < ActiveRecord::Observer
  cattr_accessor :current_user

  def after_create(issue)
    Notify.new_issue_email(issue.id) if issue.assignee != current_user
  end

  def after_change(issue)
    if issue.assignee_id_changed?
      recipient_ids = [issue.assignee_id, issue.assignee_id_was].keep_if {|id| id != current_user.id }

      recipient_ids.each do |recipient_id|
        Notify.reassigned_issue_email(recipient_id, issue.id, issue.assignee_id_was)
      end
    end
  end
end
