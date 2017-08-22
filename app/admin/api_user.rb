ActiveAdmin.register ApiUser do
  permit_params :name, :allowed_origin

  form do |f|
    f.inputs do
      f.input :name
      f.input :allowed_origin
    end
    f.actions
  end
end
