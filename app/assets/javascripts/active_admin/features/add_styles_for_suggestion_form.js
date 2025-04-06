document.addEventListener("DOMContentLoaded", function () {
    if (window.location.pathname === "/admin/recommendations/results") {
        var targetDiv = document.querySelector(".lg\\:grid-flow-col");
        if (targetDiv) {
            targetDiv.classList.remove("lg:grid-flow-col");
        }
    }
});
