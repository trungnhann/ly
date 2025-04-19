document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".data-table-resource-actions a").forEach(function (link) {
        const text = link.textContent.trim();
        if (text === "View") {
            link.classList.add("view_button");
        } else if (text === "Edit") {
            link.classList.add("edit_button");
        } else if (text === "Delete") {
            link.classList.add("delete_button");
        }
    });
});

document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".view_button").forEach(function (button) {
        button.innerHTML = '<i class="fa-solid fa-circle-info"></i>';
    });
});

document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".delete_button").forEach(function (button) {
        button.innerHTML = '<i class="fa-solid fa-trash"></i>';
    });
});
document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".edit_button").forEach(function (button) {
        button.innerHTML = '<i class="fa-solid fa-pen-to-square"></i>';
    });
});