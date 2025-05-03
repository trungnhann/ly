document.addEventListener('DOMContentLoaded', function () {
    const typeSelect = document.getElementById('certificate_type_select');
    const sections = {
        degree: document.getElementById('degree_metadata'),
        certificate: document.getElementById('certificate_metadata'),
        certification: document.getElementById('certification_metadata'),
    };

    function updateSections() {
        Object.values(sections).forEach((el) => el && (el.style.display = 'none'));
        const selected = typeSelect.value;
        if (sections[selected]) sections[selected].style.display = 'block';
    }

    typeSelect?.addEventListener('change', updateSections);
    updateSections(); // gọi ban đầu
});
