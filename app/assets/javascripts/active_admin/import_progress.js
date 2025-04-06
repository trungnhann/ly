document.addEventListener('DOMContentLoaded', () => {
  const progressBars = document.querySelectorAll('[data-progress]')

  progressBars.forEach(bar => {
    const updateProgress = async () => {
      try {
        const response = await fetch(bar.dataset.url)
        const data = await response.json()
        
        if (data.status === 'processing') {
          bar.style.width = `${data.progress}%`
          setTimeout(updateProgress, 1000)
        } else {
          window.location.reload()
        }
      } catch (error) {
        console.error('Error updating progress:', error)
      }
    }

    updateProgress()
  })
})
