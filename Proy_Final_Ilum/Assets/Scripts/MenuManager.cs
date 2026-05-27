using UnityEngine;

public class MenuManager : MonoBehaviour
{
    public GameObject menuCanvas; 

    public FirstPersonMovement playerMovement;
    public FirstPersonLook playerLook;

    private bool isMenuOpen = false;

    void Start()
    {
        ResumeGame();
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            if (isMenuOpen)
            {
                ResumeGame();
            }
            else
            {
                PauseGame();
            }
        }
    }

    private void PauseGame()
    {
        isMenuOpen = true;
        menuCanvas.SetActive(true);
        Time.timeScale = 0f; 

        Cursor.lockState = CursorLockMode.None;
        Cursor.visible = true;

        if (playerMovement != null) playerMovement.enabled = false;
        if (playerLook != null) playerLook.enabled = false;
    }

    private void ResumeGame()
    {
        isMenuOpen = false;
        menuCanvas.SetActive(false);
        Time.timeScale = 1f; 

        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;

        if (playerMovement != null) playerMovement.enabled = true;
        if (playerLook != null) playerLook.enabled = true;
    }
}