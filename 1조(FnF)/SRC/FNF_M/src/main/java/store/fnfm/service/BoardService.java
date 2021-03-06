package store.fnfm.service;

import java.util.Map;

public interface BoardService {
	void select(Map map);
	void getTotalCount(Map map);
	void deleteFaq(int idx);
	void deleteNotice(int idx);
	void deleteQaa(int idx);
	void search(Map map);
	void getSearchTotalCount(Map map);
}
