#ifndef THREADPOOL_HPP
#define THREADPOOL_HPP

#include <boost/function.hpp>
#include <boost/thread.hpp>
#include <queue>

using boost::thread_group;

class ThreadPool {
private:
    std::queue<boost::function<void()>> tasks_;
    boost::thread_group threads_;
    boost::mutex tasks_mutex_;
    boost::mutex wait_mutex_;
    boost::condition_variable tasks_cv_;
    boost::condition_variable wait_cv_;
    boost::condition_variable start_cv_;
    bool is_running_;
    size_t waiting_thread_count = 0;
    size_t pool_size_;
    bool started = false;

public:
    ThreadPool(size_t workers = 0);

    ~ThreadPool();

    template <typename Task> void add_task(Task task)
    {
        boost::lock_guard<boost::mutex> lock(tasks_mutex_);
        tasks_.push(boost::function<void()>(task));
        tasks_cv_.notify_one();
    }

    void start_and_wait();

    void stop();

private:
    void pool_main();
};

#endif /* end of include guard: THREADPOOL_HPP */