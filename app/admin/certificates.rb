ActiveAdmin.register Certificate do
  actions :all

  index do
    selectable_column
    id_column
    column :code
    column :title
    column :certificate_type
    column :issue_date
    column :expiry_date
    column :is_verified
    column :student
    column :created_at
    actions
  end

  filter :code
  filter :title
  filter :certificate_type
  filter :issue_date
  filter :expiry_date
  filter :is_verified
  filter :student
  filter :created_at

  show do
    attributes_table do
      row :id
      row :code
      row :title
      row :certificate_type
      row :issue_date
      row :expiry_date
      row :is_verified
      row :student
      row :created_at
      row :updated_at
    end

    panel 'Metadata' do
      if resource.metadata.present?
        attributes_table_for resource.metadata do
          row :issuer
          row :verification_url
          row :additional_info
          row :created_at
          row :updated_at
        end
      else
        para 'No metadata available'
      end
    end
  end

  form do |f|
    f.inputs 'Certificate Details' do
      f.input :code
      f.input :title
      f.input :certificate_type, as: :select, collection: Certificate.certificate_types.keys
      f.input :issue_date
      f.input :expiry_date
      f.input :is_verified
      f.input :student
    end
    f.actions
  end
end
