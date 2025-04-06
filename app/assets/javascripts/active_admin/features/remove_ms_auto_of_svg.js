document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll('li.group[data-open] svg').forEach(function (svg) {
        svg.classList.remove("ms-auto");
    });
});

document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll('li.group svg').forEach(function (svg) {
        svg.classList.remove("ms-auto");
    });
});