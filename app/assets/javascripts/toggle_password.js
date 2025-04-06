document.addEventListener("DOMContentLoaded", function () {
    const toggleIcons = document.querySelectorAll(".toggle-password");

    toggleIcons.forEach(function (icon) {
        icon.addEventListener("click", function () {
            const inputId = icon.getAttribute("data-target");
            const input = document.getElementById(inputId);

            if (input.type === "password") {
                input.type = "text";
                icon.classList.remove("fa-eye-slash");
                icon.classList.add("fa-eye");
            } else {
                input.type = "password";
                icon.classList.remove("fa-eye");
                icon.classList.add("fa-eye-slash");
            }
        });
    });
});
