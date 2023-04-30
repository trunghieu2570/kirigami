### Read about our contribution guidelines:

* [KDE Frameworks Coding Style](https://community.kde.org/Policies/Frameworks_Coding_Style)
* [KDE Frameworks Documentation Policy](https://community.kde.org/Frameworks/Frameworks_Documentation_Policy)

If your code contribution includes additional functionality, remember to include documentation for it.

### What does this merge request add?

(Mention **what your merge request does** and **the parts of the code that it changes**)

### Related Issues

(Link the **issues related to this merge request** here)

### Screenshot of the result (optional)

(If this merge request introduces a visual change, please **add a screenshot** by using the clip button in the upper right of this editor, otherwise leave this section blank)

### How to test this MR

```bash
git clone https://invent.kde.org/frameworks/kirigami.git
cd kirigami
git mr <THE NUMBER OF THIS MR>
cmake -B build/
cmake --build build/
source build/prefix.sh
## Compile a separate Kirigami project as normal
```

### Closes

(If this merge request closes any issue in this repository or on Bugzilla, use `Closes #<bugnumber>` here, for example: `Closes #3`)
