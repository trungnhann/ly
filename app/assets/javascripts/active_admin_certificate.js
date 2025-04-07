document.addEventListener('DOMContentLoaded', function() {
  // Chỉ thực hiện khi đang ở trang form của certificate
  if (document.querySelector('body.admin_certificates.new, body.admin_certificates.edit')) {
    const certificateTypeSelect = document.getElementById('certificate_certificate_type');
    const metadataFieldset = document.createElement('fieldset');
    metadataFieldset.className = 'inputs';
    metadataFieldset.innerHTML = '<legend><span>Metadata</span></legend>';

    // Thêm fieldset metadata vào sau certificate details
    const formInputs = document.querySelector('form.formtastic .inputs');
    if (formInputs) {
      formInputs.parentNode.insertBefore(metadataFieldset, formInputs.nextSibling);
    }

    // Định nghĩa các trường metadata cho từng loại
    const metadataFields = {
      degree: [
        { name: 'level', label: 'Cấp bậc', type: 'select', options: ['Đại học', 'Thạc sĩ', 'Tiến sĩ'] },
        { name: 'major', label: 'Ngành học', type: 'text' },
        { name: 'specialization', label: 'Chuyên ngành', type: 'text' },
        { name: 'grade', label: 'Xếp loại', type: 'text' },
        { name: 'graduation_year', label: 'Năm tốt nghiệp', type: 'number' }
      ],
      certificate: [
        { name: 'provider', label: 'Đơn vị cấp chứng chỉ', type: 'text' },
        { name: 'field', label: 'Lĩnh vực', type: 'text' },
        { name: 'score', label: 'Điểm số/Kết quả', type: 'text' },
        { name: 'level', label: 'Cấp độ/Trình độ', type: 'text' }
      ],
      certification: [
        { name: 'event', label: 'Sự kiện/Khóa học', type: 'text' },
        { name: 'achievement', label: 'Thành tích đạt được', type: 'text' },
        { name: 'duration', label: 'Thời lượng', type: 'text' },
        { name: 'organizer', label: 'Đơn vị tổ chức', type: 'text' }
      ]
    };

    // Các trường chung cho tất cả loại
    const commonFields = [
      { name: 'issuer', label: 'Đơn vị cấp', type: 'text' },
      { name: 'description', label: 'Mô tả', type: 'textarea' },
      { name: 'image_path', label: 'Đường dẫn ảnh', type: 'text' }
    ];

    function createField(field, prefix) {
      const li = document.createElement('li');
      li.className = 'string input optional stringish';
      
      const label = document.createElement('label');
      label.htmlFor = `certificate_metadata_${prefix}_${field.name}`;
      label.textContent = field.label;
      
      let input;
      if (field.type === 'select') {
        input = document.createElement('select');
        field.options.forEach(option => {
          const opt = document.createElement('option');
          opt.value = option.toLowerCase();
          opt.textContent = option;
          input.appendChild(opt);
        });
      } else if (field.type === 'textarea') {
        input = document.createElement('textarea');
      } else {
        input = document.createElement('input');
        input.type = field.type;
      }
      
      input.id = `certificate_metadata_${prefix}_${field.name}`;
      input.name = `certificate[metadata][${prefix}_info][${field.name}]`;
      
      li.appendChild(label);
      li.appendChild(input);
      return li;
    }

    function updateMetadataFields() {
      const selectedType = certificateTypeSelect.value;
      const ol = document.createElement('ol');

      // Thêm các trường chung
      commonFields.forEach(field => {
        ol.appendChild(createField(field, ''));
      });

      // Thêm các trường specific theo loại
      const typeFields = metadataFields[selectedType];
      if (typeFields) {
        typeFields.forEach(field => {
          ol.appendChild(createField(field, `${selectedType}_info`));
        });
      }

      // Cập nhật giao diện
      metadataFieldset.innerHTML = '<legend><span>Metadata</span></legend>';
      metadataFieldset.appendChild(ol);
    }

    // Theo dõi sự thay đổi của certificate_type
    if (certificateTypeSelect) {
      certificateTypeSelect.addEventListener('change', updateMetadataFields);
      // Khởi tạo ban đầu
      updateMetadataFields();
    }
  }
});