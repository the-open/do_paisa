ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  page_action :upload_po_csv, method: :post do
    path = params[:file]
    UploadPODonationsWorker.perform_async(path)
    redirect_to admin_dashboard_path, notice: "Your csv is being imported..."
  end

  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel 'PO CSV Import' do
          ul do
            render 'admin/dashboard/upload_po_csv'
          end
        end
      end
    end
  end
end
