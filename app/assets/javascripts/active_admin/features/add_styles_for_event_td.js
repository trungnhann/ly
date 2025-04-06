document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll('td[data-column="event"]').forEach(function (td) {
        const eventType = td.textContent.trim();
        if (eventType === "create") {
            td.classList.add("event_create");
        } else if (eventType === "update") {
            td.classList.add("event_update");
        } else if (eventType === "destroy") {
            td.classList.add("event_destroy");
        }
    });
});