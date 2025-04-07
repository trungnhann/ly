document.addEventListener('DOMContentLoaded', function () {
    var typeSelect = document.getElementById('certificate_type_select');
    if (!typeSelect) return;

    var degreeMetadata = document.getElementById('degree_metadata');
    var certificateMetadata = document.getElementById('certificate_metadata');
    var certificationMetadata = document.getElementById('certification_metadata');

    function updateMetadataFields() {
        var selectedType = typeSelect.value;

        // Ẩn tất cả các phần
        if (degreeMetadata) degreeMetadata.style.display = 'none';
        if (certificateMetadata) certificateMetadata.style.display = 'none';
        if (certificationMetadata) certificationMetadata.style.display = 'none';

        // Hiện phần phù hợp
        if (selectedType === 'degree' && degreeMetadata) {
            degreeMetadata.style.display = 'block';
        } else if (selectedType === 'certificate' && certificateMetadata) {
            certificateMetadata.style.display = 'block';
        } else if (selectedType === 'certification' && certificationMetadata) {
            certificationMetadata.style.display = 'block';
        }
    }

    updateMetadataFields();
    typeSelect.addEventListener('change', updateMetadataFields);
});
